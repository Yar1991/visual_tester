# Visual Tester

A visual regression testing tool powered by n8n, Browserless, Gemini AI, and Caddy.

## Prerequisites

- Docker
- Docker Compose

## Setup

1.  **Clone the repository.**
2.  **Create a `.env` file** based on the provided example.

    ```bash
    cp .env.example .env
    ```

    Open `.env` and fill in the required values (e.g., `DOMAIN_NAME`, `POSTGRES_PASSWORD`, `AI_API_KEY`, `SLACK_WEBHOOK`, `TARGET_WEBSITE_URL`).

3.  **Start the services:**

    ```bash
    docker-compose up -d
    ```

## Workflows

This project includes two main n8n workflows that are automatically imported:

### 1. Visual Tester (Daily Check)
-   **Schedule:** Runs daily at 10:00 AM.
-   **Trigger:** Can also be triggered manually.
-   **Process:**
    -  **Fetch Sitemap:** Retrieves URLs from `TARGET_WEBSITE_URL/sitemap.xml`.
    -  **Take Screenshots:** Captures screenshots for both **Desktop** (1920x1080) and **Mobile** (393x852) viewports using Browserless.
    -  **Pixel Comparison:** Compares the new screenshot against the existing baseline.
        -   **Exact Match:** Pass.
        -   **Mismatch:** Sends both images to **Gemini Vision AI**.
    -  **AI Analysis:** Gemini checks if the difference is a real issue or just rendering noise.
        -   **Pass:** If the difference is negligible.
        -   **Fail:** If a critical visual bug is detected.
    -  **Report Generation:** Creates a detailed HTML report with side-by-side comparisons and highlights.
    -  **Notification:** Sends a summary to Slack with a link to the report.

### 2. Visual Testing - Updater
-   **Trigger:** Webhook (called from the HTML Report).
-   **Function:** When a user clicks "Accept New Version" in the report, this workflow updates the baseline image with the new screenshot.
-   **Security:** Protected by `UPDATE_BASELINE_TOKEN`.

## Architecture

-   **n8n**: The workflow engine orchestrating the tests.
-   **Browserless**: Headless Chrome instance for rendering pages and taking screenshots.
-   **Caddy**: Reverse proxy and static file server for hosting the evidence images and HTML reports.
-   **Postgres**: Database for n8n.

## Usage

1.  Access n8n at `https://your-domain.com` (or `http://localhost:5678` if running locally without a domain).
2.  The visual testing report will be generated in `local_files/reports/` and accessible via the web if configured.
3.  Check Slack for daily notifications.
