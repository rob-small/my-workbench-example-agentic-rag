# My Dell Agentic RAG

This branch customizes the NVIDIA Agentic RAG sample into a Dell-focused demo that adds guided onboarding, richer observability, and optional self-hosted inference controls. The Gradio UI now walks new users through a scripted evaluation workflow, ships with Dell collateral preloaded for Retrieval-Augmented Generation (RAG), and exposes per-component prompts and deployment knobs for experimentation.

## What changed in this branch?
- **Dell-flavored quickstart and sample data** – four one-click sample questions and a curated set of Dell URLs are preloaded so users can immediately compare non-RAG and RAG runs.
- **Guided setup inside the app** – a "Quickstart" tab explains a five-step evaluation loop directly in the UI, reducing the need to reference external docs.
- **Configurable agent pipeline** – the "Models" tab lets you choose per-component NVIDIA API endpoints or point each stage (router, retrieval grader, generator, hallucination grader, answer grader) at a self-hosted NIM, while exposing the prompts used by default Dell-tuned templates.
- **Context creation workflow** – web and file upload flows embed data into a persistent Chroma store under `/project/data`, with helpers for splitting, embedding, and clearing content.
- **Monitoring & troubleshooting** – the "Monitor" tab streams live LangGraph traces and timestamped logs captured via a lightweight logger, and friendly error messages surface common Tavily, auth, and recursion failures.
- **Self-hosting aides** – optional GPU compatibility checks and a reference Docker Compose file help teams run their own NIM endpoints with validated model/GPU pairs.

## Architecture refresher
The agent is implemented with LangGraph. Incoming questions are routed to either Tavily web search or the Dell document vector store, retrieved passages are filtered, and candidate answers are graded for hallucinations and usefulness before being accepted or retried.

### Default prompts
Two prompt suites are bundled:
- **Llama 3.1** prompts tuned for Dell terminology and evaluation criteria.
- **Mixtral** equivalents for users who prefer Mistral endpoints.
You can edit these directly in the UI accordions or by modifying the prompt modules.

## Setup
1. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```
2. **Configure environment variables**
   - `NVIDIA_API_KEY` – required for NVIDIA API-backed inference.
   - `TAVILY_API_KEY` – enables web search via Tavily.
   - `INTERNAL_API` (optional) – set to `yes` to switch the default model IDs to internal NVIDIA endpoints; defaults to `no`.
   - `RECURSION_LIMIT` – caps LangGraph retries (default 10).
   - `TAVILY_K` – number of Tavily results to merge into context (default 3).
   - `CHUNK_SIZE` / `CHUNK_OVERLAP` – control document chunking before embedding.
   Additional variables, such as embedding choices, can be adjusted by editing `variables.env` or exporting them before launch.
3. **Launch the Gradio app**
   ```bash
   python -m chatui
   ```
   This starts the UI on port 8080 with the conversation page mounted at the root.

## Using the app
### 1. Follow the Quickstart tour
Use the five guided steps to benchmark the preloaded sample queries with and without RAG context. Each step toggles explanatory Markdown so you can focus on one task at a time.

### 2. Seed the context with Dell knowledge
The Documents → Webpages tab is pre-populated with Dell blog posts about Agentic RAG. Click **Add to Context** to fetch, split, and embed them. You can also upload PDFs, CSVs, Markdown, or text files in the Files tab.

### 3. Customize the agent stack
Open the Models tab to adjust each stage:
- Pick API-hosted models (Llama 3.1, Mixtral) or toggle to **Self-Hosted Endpoint** to enter your NIM host, port, and model ID.
- Expand the prompt accordions to fine-tune routing, retrieval grading, answer generation, hallucination checks, and answer scoring without redeploying.

### 4. Monitor actions and logs
The Monitor tab shows LangGraph traces alongside timestamped logs produced during each interaction. Use this view to understand routing decisions, grading outcomes, and why the agent may re-query web search.

### 5. Troubleshoot with contextual tips
When Tavily, authentication, or recursion issues occur, the UI surfaces markdown guidance pulled from `QUERY_ERROR_MESSAGES`. Start by checking the Monitor tab logs the message references.

## Self-hosted inference options
Want to run everything on-prem?
1. **Deploy a reference NIM** – `compose.yaml` starts a local Llama 3.1 NIM listening on port 8000 with your NVIDIA API key.
2. **Validate GPU/model fit** – the GPU compatibility helper guards against unsupported pairings by consulting `nim_gpu_support_matrix.json`.
3. **Point the UI at your endpoint** – switch any component to **Self-Hosted Endpoint** and provide the host, port, and model ID. Optional GPU type/count validation is available if you uncomment the dropdowns in the UI.

## Data storage
Embedded documents persist under `/project/data` via Chroma, so the context survives container restarts until you click **Clear Context**, which wipes the collection and associated shard files.

## Additional resources
Deeper customization guides live in `agentic-rag-docs/` for editing code (`intermediate-edit-code.md`) and self-hosting (`self-host.md`).

## License
This project remains under the Apache 2.0 license as noted in `LICENSE.txt`.
