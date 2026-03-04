# Self Hosted Printing Server

> Are you tired of your relatives asking you to print something for them? Well, now they can do it themselves! Even if they are not on your local network.

![image](https://github.com/user-attachments/assets/e91a0fb0-2502-4dda-803c-2a579004a242)

## 🚀 Quick Start with Docker Compose

### Prerequisites

- **Docker** and **Docker Compose** installed on your system
- **IPP-compatible printer** on your network with IPP enabled
- **Network access** to your printer from the server

### 1. Clone the Repository

```bash
git clone https://github.com/Akronae/self-hosted-printing-server
cd self-hosted-printing-server
```

### 2. Create Docker Compose Configuration

Create a `docker-compose.yaml` file in the project root:

```yaml
# docker-compose.yaml
services:
  api:
    image: ghcr.io/pdrg2heusdi3adyenlt94/self-hosted-printing-server-api:latest  # <--- your actual GitHub username (lowercase)
    ports:
      - 3001:3001
    environment:
      DATABASE_URL: "file:./dev.db"
      JWT_SECRET: "your-secure-jwt-secret-here" # Place a randomly generated secret here (e.g. using `openssl rand -base64 32`)
      ADMIN_USER: "admin"
      ADMIN_PWD: "your-secure-password-here"       # <--- your admin password
      PRINTER_URL: "http://192.168.xx.xx:631"          # <--- your printer's IP
    volumes:
      - db:/usr/src/app/prisma
    restart: unless-stopped

  frontend:
    image: ghcr.io/pdrg2heusdi3adyenlt94/self-hosted-printing-server-frontend:latest  # <--- same username
    ports:
      - 3000:80
    environment:
      PUBLIC_API_URL: "http://192.168.xx.xx:3001"    # <--- your server's LAN IP, not localhost
    depends_on:
      - api
    restart: unless-stopped

volumes:
  db:
```

### 3. Configure Your Settings

**Important**: Update the following values in your `docker-compose.yaml`:

| Variable         | Description                               | Example                          |
| ---------------- | ----------------------------------------- | -------------------------------- |
| `JWT_SECRET`     | Secure secret for JWT tokens              | `your-super-secret-jwt-key-here` |
| `ADMIN_PWD`      | Admin panel password                      | `your-secure-admin-password`     |
| `PRINTER_URL`    | Your printer's IPP endpoint               | `http://192.168.1.100:631`       |
| `PUBLIC_API_URL` | API URL (use server IP for remote access) | `http://192.168.1.50:3001`       |

### 4. Start the Services

```bash
# Build and start all services
docker-compose up -d

# View logs (optional)
docker-compose logs -f
```

### 5. Access the Application

- **Frontend**: http://localhost:3000
- **API**: http://localhost:3001
- **API Documentation**: http://localhost:3001/api (Swagger UI)

## 📱 Usage

1. **Access the web interface** at http://localhost:3000
2. **Upload your files** (PDF, images, documents)
3. **Configure print settings** (pages, copies, quality)
4. **Send to printer** - files are automatically converted and printed

## 🖨️ Printer Setup

### Finding Your Printer's IP Address

1. **From printer menu**: Check network settings on your printer's display
2. **Router admin panel**: Look for connected devices
3. **Network scanning**: Use `nmap` or similar tools
   ```bash
   nmap -sn 192.168.1.0/24
   ```

### Verify IPP Support

Test if your printer accepts IPP connections:

```bash
# Test printer connectivity
curl -I http://YOUR_PRINTER_IP:631/

# List available printers (if CUPS is accessible)
lpstat -p -d
```

Most modern printers support IPP on port 631 by default.

## ⚙️ Configuration

### Environment Variables

| Variable         | Required | Default         | Description                       |
| ---------------- | -------- | --------------- | --------------------------------- |
| `DATABASE_URL`   | Yes      | `file:./dev.db` | SQLite database location          |
| `JWT_SECRET`     | Yes      | -               | Secret key for JWT authentication |
| `ADMIN_USER`     | Yes      | `admin`         | Admin username                    |
| `ADMIN_PWD`      | Yes      | -               | Admin password                    |
| `PRINTER_URL`    | Yes      | -               | Printer IPP endpoint              |
| `PUBLIC_API_URL` | Yes      | -               | API URL for frontend              |

### Persistent Data

The compose setup includes volumes for:

- **Database**: Stores user data, print history
- **Uploads**: Temporary file storage during processing

## 🔧 Management Commands

```bash
# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs api
docker-compose logs frontend

# Update and rebuild
git pull
docker-compose down
docker-compose up -d --build

# Clean up
docker-compose down -v  # ⚠️ This removes volumes (data loss)
```

## 🌐 Remote Access

To access from other devices on your network:

1. **Update `PUBLIC_API_URL`** to use your server's IP:

   ```yaml
   PUBLIC_API_URL: "http://192.168.1.50:3001"
   ```

2. **Rebuild frontend**:

   ```bash
   docker-compose up -d --build frontend
   ```

3. **Access via server IP**: http://192.168.1.50:3000

## 🛠️ Troubleshooting

### Common Issues

**Container won't start**:

```bash
docker-compose logs api
docker-compose logs frontend
```

**Printer not found**:

- Verify printer IP and port 631 accessibility
- Check if IPP is enabled on your printer
- Test connection: `telnet PRINTER_IP 631`

**Build failures**:

```bash
# Clean build
docker-compose down
docker system prune -f
docker-compose up -d --build
```

**Permission issues**:

```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Log Locations

- **API logs**: `docker-compose logs api`
- **Frontend logs**: `docker-compose logs frontend`
- **Build logs**: Include `--no-cache` flag when building

## 🏗️ Development Setup

For development with hot-reload:

```bash
# Install dependencies
cd api && yarn install
cd ../front && yarn install

# Run in development mode
cd api && yarn dev
cd front && yarn dev
```

## 📄 How It Works

The system consists of two main components:

1. **API Backend (NestJS)**:

   - Receives file uploads via REST API
   - Converts files to JPEG format using `pdf-to-img` and `canvas`
   - Sends print jobs to printer via IPP protocol
   - Handles authentication and print history

2. **Frontend (React/TypeScript)**:
   - Provides web interface for file uploads
   - Print configuration and management
   - Real-time print status updates

**Print Process**:

1. User uploads file through web interface
2. API converts file to printable JPEG format
3. Print job sent to printer via IPP
4. Status updates displayed in frontend

## 📝 License

MIT License - see LICENSE file for details.
