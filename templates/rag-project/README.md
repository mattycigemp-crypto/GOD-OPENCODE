# {{PROJECT_NAME}} - RAG Project

## Purpose

A production-ready Retrieval-Augmented Generation (RAG) system with document ingestion, vector storage, semantic search, and LLM-powered answer generation.

## Prerequisites

- Python 3.11+
- OpenAI or Anthropic API key
- uv

## Setup

1. **Install dependencies**
   ```bash
   uv venv && source .venv/bin/activate
   uv pip install -r requirements.txt
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Set OPENAI_API_KEY, VECTOR_STORE_PATH, etc.
   ```

3. **Ingest your documents**
   ```bash
   python -m app.ingest --source ./docs
   ```

4. **Start the API server**
   ```bash
   uvicorn app.api:app --reload
   ```

5. **Query the system**
   ```bash
   curl -X POST http://localhost:8000/query \
     -H "Content-Type: application/json" \
     -d '{"question": "What is the refund policy?"}'
   ```

## Project Structure

```
app/
  ingest.py          # Document ingestion pipeline
  retriever.py       # Vector search and reranking
  generator.py       # LLM answer generation
  api.py             # FastAPI query endpoint
  config.py          # Configuration management
data/
  raw/               # Source documents
  processed/         # Chunked and processed docs
  vectors/           # Local vector store (if using Chroma)
eval/
  questions.json     # Evaluation question set
  evaluate.py        # Evaluation runner
tests/               # Test suite
```

## Architecture

```
Documents → Chunking → Embedding → Vector Store
                                        ↓
User Query → Embedding → Retrieval → Reranking → LLM → Answer
```

## Running Evaluation

```bash
python eval/evaluate.py --questions eval/questions.json
```

## Dependencies

- langchain / llama-index - RAG orchestration
- openai / anthropic - LLM providers
- chromadb - local vector store
- sentence-transformers - embedding models
- fastapi, uvicorn - API server
- pytest - testing

