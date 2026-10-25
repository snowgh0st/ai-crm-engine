
# AI-Powered Enterprise Knowledge Workflow & CRM Enrichment Engine

[![Ruby](https://img.shields.io/badge/Ruby-3.3%2B-red?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Ruby on Rails](https://img.shields.io/badge/Rails-7.1%2B-cc0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169e1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![pgvector](https://img.shields.io/badge/pgvector-HNSW-blue?logo=postgresql&logoColor=white)](https://github.com/pgvector/pgvector)
[![Sidekiq](https://img.shields.io/badge/Sidekiq-Background%20Jobs-purple?logo=sidekiq&logoColor=white)](https://sidekiq.org/)
[![OpenAI](https://img.shields.io/badge/OpenAI-API-412991?logo=openai&logoColor=white)](https://openai.com/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-CSS-38bdf8?logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)

---

## Overview

The **AI-Powered Enterprise Knowledge Workflow & CRM Enrichment Engine** is an enterprise-grade backend and web application built to ingest, vectorize, search, and autonomously enrich unstructured customer relationship management (CRM) notes, emails, security reviews, and knowledge base articles. 

Leveraging native PostgreSQL vector extensions (`pgvector`) with compiled HNSW indexes, asynchronous background job workers via Sidekiq, and OpenAI's structured JSON completions (`gpt-4o-mini`), this engine bridges the gap between raw unstructured enterprise text and actionable, AI-classified metadata.

---

## Key Features

- **Blazing-Fast Semantic Search:** Converts natural language queries into 1536-dimensional vector embeddings (`text-embedding-3-small`) and executes sub-millisecond approximate nearest neighbor searches via PostgreSQL HNSW indexes (`vector_cosine_ops`).
- **Asynchronous AI Metadata Enrichment:** Automatically triggers background job workers (`CrmEnrichmentJob`) upon record creation to fetch historical vector context and extract structured JSON metadata (sentiment, priority, account classification tags, and actionable next steps).
- **Executive Tailwind CSS Dashboard:** A modern dark-mode responsive web interface featuring real-time document ingestion forms, instant vector similarity scoring badges, and structured CRM insight inspectors.
- **Versioned REST API:** Stateless API endpoints (`POST /api/v1/search`) configured with CSRF exemptions for seamless integration with external applications, microservices, and programmatic cURL clients.

---

## Architecture & Data Flow

```text
[ Client Layer ]
  ├── Tailwind CSS Dashboard ──> Rails Controllers (Dashboard / Documents)
  └── API Clients / cURL ------> Api::V1::SearchController (HNSW Vector Search)

[ Rails Application Layer ]
  ├── Document Model (ActiveRecord callbacks)
  ├── EmbeddingGenerator Service (OpenAI: text-embedding-3-small)
  └── CrmEnrichmentService (OpenAI: gpt-4o-mini JSON mode)

[ Background Processing Layer ]
  └── Sidekiq Worker (CrmEnrichmentJob via Redis) 
        └─> Asynchronously fetches vector context & enriches metadata

[ Data Storage & AI Layer ]
  ├── PostgreSQL 16 + pgvector (1536-dim vector column + HNSW Index)
  └── OpenAI API (Embeddings & Structured Completions)

```

---

## Tech Stack

* **Backend Framework:** Ruby on Rails 7 (API & MVC)
* **Database:** PostgreSQL 16 with compiled `pgvector` extension
* **ActiveRecord Integration:** `neighbor` gem for HNSW cosine distance vector queries
* **Background Processing:** Sidekiq & Redis
* **AI & LLM Integration:** `ruby-openai` (`text-embedding-3-small`, `gpt-4o-mini`)
* **Frontend UI:** Tailwind CSS (`tailwindcss-rails`), Importmaps, Framer-inspired aesthetics
* **Environment Management:** `dotenv-rails`

---

## Project Structure

```text
app/
├── controllers/
│   ├── api/v1/search_controller.rb   # Versioned RESTful semantic search endpoint
│   ├── dashboard_controller.rb       # Executive web dashboard controller
│   └── documents_controller.rb       # Web form ingestion handler
├── jobs/
│   └── crm_enrichment_job.rb         # Sidekiq background worker for async AI metadata
├── models/
│   └── document.rb                   # ActiveRecord model with vector & callback hooks
├── services/
│   ├── embedding_generator.rb        # OpenAI embedding conversion service
│   └── crm_enrichment_service.rb     # OpenAI structured JSON metadata enrichment service
└── views/
    └── dashboard/index.html.erb      # Tailwind CSS executive dashboard interface

```

---

## Local Development & Setup

### Prerequisites

* **Ruby:** `3.3+`
* **PostgreSQL:** `16+` with `pgvector` extension installed (`CREATE EXTENSION vector;`)
* **Redis:** Running locally for Sidekiq background workers

### 1. Clone the Repository

```bash
git clone [https://github.com/your-username/ai-crm-engine.git](https://github.com/your-username/ai-crm-engine.git)
cd ai-crm-engine

```

### 2. Install Dependencies

```bash
bundle install

```

### 3. Configure Environment Variables

Create a `.env` file in the root directory and add your OpenAI API key:

```env
OPENAI_API_KEY=your_openai_api_key_here

```

### 4. Setup Database

```bash
bin/rails db:create
bin/rails db:migrate

```

### 5. Run the Application (Rails Server + Tailwind Watcher + Sidekiq)

Start your development environment:

```bash
bin/dev

```

*(Alternatively, run `bin/rails s` in one tab and `bundle exec sidekiq` in another).*

Visit `http://localhost:3000` in your browser.

---

## API Reference

### Semantic Vector Search

* **Endpoint:** `POST /api/v1/search`
* **Content-Type:** `application/json`

#### Request Body:

```json
{
  "query": "How do we handle background jobs and error retries?"
}

```

#### Response (`200 OK`):

```json
[
  {
    "id": 1,
    "title": "Sidekiq Infrastructure Overview",
    "content": "All background tasks are processed via Sidekiq and Redis with exponential backoff retries...",
    "source_type": "kb_article",
    "metadata": {
      "enrichment": {
        "sentiment": "positive",
        "priority": "medium",
        "action_items": ["Review Sidekiq concurrency limits"],
        "account_tag": "Internal Ops"
      }
    },
    "similarity_score": 0.9245
  }
]

```

---

## License

Distributed under the **MIT License**. See `LICENSE` for more information.
