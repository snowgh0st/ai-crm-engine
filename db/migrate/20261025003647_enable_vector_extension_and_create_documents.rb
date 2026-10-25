# frozen_string_literal: true

class EnableVectorExtensionAndCreateDocuments < ActiveRecord::Migration[7.1]
  def change
    # =========================================================================
    # PATH MAPPING:
    # - Hot Path: Successful extension loading and table creation with HNSW index.
    # - Execution Path: Executing native PostgreSQL DDL commands for vector search.
    # - Sad Path: Database missing vector extension support or migration rollback.
    # =========================================================================

    # 1. Enable the pgvector extension in PostgreSQL
    # Hot/Execution Path: Registers vector data types and similarity operators (<->, <#>, <=>).
    # Sad Path: Raises error if pgvector isn't installed in the PostgreSQL instance.
    enable_extension 'vector' unless extension_enabled?('vector')

    # 2. Create the documents table for storing enterprise knowledge chunks
    create_table :documents do |t|
      t.string   :title, null: false
      t.text     :content, null: false
      t.string   :source_type, default: 'manual' # e.g., pdf, email, CRM record
      t.jsonb    :metadata, default: {}          # Flexible metadata store
      
      # Vector embedding column configured for OpenAI text-embedding-3-small (1536 dimensions)
      # Execution Path: Stores high-dimensional dense vectors for semantic similarity search.
      t.column   :embedding, 'vector(1536)'

      t.timestamps
    end

    # 3. Add performance indices
    # Hot Path: Indexing metadata JSONB for fast filtering
    add_index :documents, :metadata, using: :gin
    
    # Hot Path: HNSW (Hierarchical Navigable Small World) index for blazing-fast approximate nearest neighbor vector search
    # Execution Path: Optimized for high-recall vector similarity lookups during RAG retrieval.
    execute <<-SQL
      CREATE INDEX documents_embedding_hnsw_idx ON documents 
      USING hnsw (embedding vector_cosine_ops)
      WITH (m = 16, ef_construction = 64);
    SQL
  end
end