# Simple Drive Project

A Ruby on Rails application providing APIs to store and retrieve objects/files using an id, name, or path. The application supports multiple storage backends, including Amazon S3-compatible storage, local file system, database table, and FTP (bonus).

## Table of Contents
- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Database Setup](#database-setup)
- [Usage](#usage)
- [Testing](#testing)
- [Contributing](#contributing)

---

## Features

1. **Multiple Storage Backends**:
   - Amazon S3-compatible storage
   - Local file system
   - Database table
   - FTP (Bonus feature)

2. **API Endpoints**:
   - Store a blob: `POST /v1/blobs`
   - Retrieve a blob: `GET /v1/blobs/<id>`

3. **Authentication**:
   - Bearer token authentication for all requests.

4. **Response Format**:
   - Returns blob information in JSON format, including size and creation timestamp (for database storage).

---

## System Requirements

- Ruby: 2.7.x or higher
- Rails: 6.x or higher
- PostgreSQL or MySQL database
- AWS SDK (optional for Amazon S3-compatible storage)
- Local file system access (for local storage)

---

## Installation

1. Clone the repository:
   ```bash
   git clone [your-repository-url]
   cd simple_drive_project
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Setup environment variables:
   - Create a `.env` file in the project root with your configuration (e.g., storage backend, AWS credentials).

4. Database setup:
   - Run database migrations:
     ```bash
     rails db:migrate
     ```

---

## Configuration

### Storage Backends

#### 1. Amazon S3-Compatible Storage:
- Configure AWS SDK in `config/storage.yml`:
  ```yaml
  amazon_s3:
    service: 's3'
    region: 'your-region' # e.g., us-east-1
    access_key_id: 'your-access-key-id'
    secret_access_key: 'your-secret-access-key'
  ```

#### 2. Local File System:
- Configure local storage in `config/storage.yml`:
  ```yaml
  local:
    root: '/path/to/your/local/storage/directory'
  ```

#### 3. Database Table:
- Create a `Blobs` table in your database to store blob metadata.

#### 4. FTP (Bonus):
- Configure FTP server credentials in the environment variables or directly in your application code.

---

## Database Setup

### Creating the Blobs Table
Run the following migration:
```bash
rails generate migration CreateBlobsTable
```
The migration file should include fields like `id`, `blob_id` (unique identifier), `filename`, `size`, and `created_at`.

Apply the migrations:
```bash
rails db:migrate
```

### Initializing the Database
Run database initialization scripts if needed:
```bash
rails db:seed
```

---

## Usage

1. **Storing a Blob**:
   - Send a POST request to `/v1/blobs` with a JSON payload:
     ```json
     {
       "id": "your-unique-id",
       "data": "base64-encoded-binary-data"
     }
     ```
   - Example using `curl`:
     ```bash
     curl -X POST http://localhost:3000/v1/blobs \
       -H "Content-Type: application/json" \
       -H "Authorization: Bearer your-token" \
       -d '{"id":"test-id", "data":"base64-encoded-string"}'
     ```

2. **Retrieving a Blob**:
   - Send a GET request to `/v1/blobs/<id>`:
     ```bash
     curl -X GET http://localhost:3000/v1/blobs/test-id \
       -H "Authorization: Bearer your-token"
     ```

---

## Testing

### Running Tests
- Write unit and integration tests for your controllers, models, and services.
- Run tests using:
  ```bash
  rails test
  ```

### Example Test Suite Structure
1. **Model Tests**:
   - Test the `Blobs` model validations and methods.

2. **Controller Tests**:
   - Test API endpoints for storing and retrieving blobs.

3. **Integration Tests**:
   - Test the end-to-end flow of blob storage and retrieval.

---

## Contributing

- Fork the repository on GitHub.
- Create a feature branch.
- Commit your changes, ensuring tests pass.
- Push to the branch and open a Pull Request.

---

## License

 
(c) 2025 Mohammed Alghanmi MIT License.
