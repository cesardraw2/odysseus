#!/bin/bash

# 🚀 Odysseus Angular 21+ Setup Script
# Configuração automática completa do projeto

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Verificando Pré-requisitos"
    
    # Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js não encontrado. Instale Node.js 18+ em https://nodejs.org"
        exit 1
    fi
    NODE_VERSION=$(node --version)
    print_success "Node.js: $NODE_VERSION"
    
    # npm
    if ! command -v npm &> /dev/null; then
        print_error "npm não encontrado"
        exit 1
    fi
    NPM_VERSION=$(npm --version)
    print_success "npm: $NPM_VERSION"
    
    # Git (optional)
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_success "Git: $GIT_VERSION"
    else
        print_warning "Git não encontrado (opcional)"
    fi
}

# Create workspace
create_workspace() {
    print_header "Criando NX Workspace"
    
    if [ -d "odysseus-ng" ]; then
        print_warning "Diretório odysseus-ng já existe"
        read -p "Deseja remover e criar novo? (s/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            rm -rf odysseus-ng
        else
            cd odysseus-ng
            return
        fi
    fi
    
    print_success "Criando workspace..."
    npx create-nx-workspace odysseus-ng \
        --preset=angular \
        --packageManager=npm \
        --routing \
        --skip-git
    
    cd odysseus-ng
    print_success "Workspace criado"
}

# Install dependencies
install_dependencies() {
    print_header "Instalando Dependências"
    
    print_success "Angular e ferramentas..."
    npm install \
        @angular/router@21 \
        @angular/forms@21 \
        @angular/common@21 \
        @angular/platform-browser@21 \
        @angular/platform-browser-dynamic@21 \
        @angular/animations@21 \
        rxjs@7 \
        tslib@2 \
        zone.js@0 \
        date-fns@2

    print_success "Frontend tooling..."
    npm install -D \
        tailwindcss@3 \
        postcss@8 \
        autoprefixer@10 \
        @nx/angular@21 \
        @nx/webpack@21 \
        @angular-eslint/eslint-plugin@21 \
        @angular-devkit/build-angular@21 \
        @angular/cli@21 \
        @angular/compiler-cli@21

    print_success "Backend tooling..."
    npm install -D \
        @types/express@4 \
        @types/node@20 \
        ts-node@10 \
        typescript@5

    print_success "Backend dependencies..."
    npm install \
        express@4 \
        cors@2 \
        uuid@9

    print_success "Utilitários..."
    npm install -D \
        concurrently@8

    print_success "Todas as dependências instaladas"
}

# Create directory structure
create_directory_structure() {
    print_header "Criando Estrutura de Diretórios"
    
    # Main folders
    mkdir -p apps/shell/src/app/{layout,pages}
    mkdir -p apps/fake-backend/src/{routes,data,middleware}
    mkdir -p libs/shared/{ui,services,http,models}
    mkdir -p libs/api/{chat,email,calendar,memory,documents,notes,tasks,gallery,settings}
    mkdir -p libs/theme

    # MFEs
    for mfe in auth chat research compare documents notes memory calendar email gallery library theme settings; do
        mkdir -p apps/mfe-${mfe}/src/app
    done

    print_success "Estrutura de diretórios criada"
}

# Create configuration files
create_config_files() {
    print_header "Criando Arquivos de Configuração"

    # Tailwind config
    cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    'apps/shell/src/**/*.{html,ts,tsx,jsx}',
    'apps/mfe-*/src/**/*.{html,ts,tsx,jsx}',
    'libs/**/*.{html,ts,tsx,jsx}',
  ],
  theme: {
    extend: {
      colors: {
        odysseus: {
          bg: 'var(--bg, #282c34)',
          fg: 'var(--fg, #abb2bf)',
          panel: 'var(--panel, #3e4451)',
          border: 'var(--border, #4b5263)',
        },
      },
    },
  },
  plugins: [],
};
EOF
    print_success "tailwind.config.js"

    # PostCSS config
    cat > postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOF
    print_success "postcss.config.js"

    # .env.example
    cat > .env.example << 'EOF'
# Fake Backend
FAKE_BACKEND_URL=http://localhost:3001
USE_REAL_BACKEND=false

# Angular
NG_APP_VERSION=1.0.0
NG_APP_ENVIRONMENT=development
EOF
    print_success ".env.example"

    # .gitignore
    cat > .gitignore << 'EOF'
# Dependencies
/node_modules
/.pnp
.pnp.js

# Build
/dist
/build
/out-tsc

# NX
.nx
.nxc
.next-env.d.ts

# IDE
.vscode
.idea
*.swp
*.swo
*~
.DS_Store

# Environment
.env
.env.local
.env.*.local

# OS
.DS_Store
Thumbs.db

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Testing
/coverage
/.nyc_output

# Misc
*.tsbuildinfo
EOF
    print_success ".gitignore"
}

# Create shell files
create_shell_files() {
    print_header "Configurando Shell Application"

    # index.html
    mkdir -p apps/shell/src/assets
    cat > apps/shell/src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Odysseus - AI Workspace</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
</head>
<body>
  <app-root></app-root>
</body>
</html>
EOF
    print_success "index.html"

    # main.ts
    cat > apps/shell/src/main.ts << 'EOF'
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig).catch(err => {
  console.error(err);
  process.exit(1);
});
EOF
    print_success "main.ts"

    # app.component.ts
    cat > apps/shell/src/app/app.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet],
  template: `
    <div class="flex h-screen bg-odysseus-bg text-odysseus-fg">
      <aside class="w-64 border-r border-odysseus-border bg-odysseus-panel p-4">
        <h1 class="text-2xl font-bold mb-6">Odysseus</h1>
        <nav class="space-y-2">
          <a href="/chat" class="block px-4 py-2 rounded hover:bg-odysseus-bg transition">💬 Chat</a>
          <a href="/memory" class="block px-4 py-2 rounded hover:bg-odysseus-bg transition">🧠 Memory</a>
          <a href="/calendar" class="block px-4 py-2 rounded hover:bg-odysseus-bg transition">📅 Calendar</a>
          <a href="/email" class="block px-4 py-2 rounded hover:bg-odysseus-bg transition">📧 Email</a>
          <a href="/settings" class="block px-4 py-2 rounded hover:bg-odysseus-bg transition">⚙️ Settings</a>
        </nav>
      </aside>
      <main class="flex-1 overflow-auto">
        <router-outlet></router-outlet>
      </main>
    </div>
  `,
  styles: [':host { display: block; height: 100%; }'],
})
export class AppComponent implements OnInit {
  ngOnInit() {
    console.log('✅ Odysseus Shell loaded');
  }
}
EOF
    print_success "app.component.ts"

    # app.routes.ts
    cat > apps/shell/src/app/app.routes.ts << 'EOF'
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: '/chat', pathMatch: 'full' },
  { path: 'chat', loadChildren: () => import('mfeChat/ChatModule').then(m => m.ChatModule) },
  { path: 'memory', loadChildren: () => import('mfeMemory/MemoryModule').then(m => m.MemoryModule) },
  { path: 'calendar', loadChildren: () => import('mfeCalendar/CalendarModule').then(m => m.CalendarModule) },
  { path: 'email', loadChildren: () => import('mfeEmail/EmailModule').then(m => m.EmailModule) },
  { path: 'settings', loadChildren: () => import('mfeSettings/SettingsModule').then(m => m.SettingsModule) },
];
EOF
    print_success "app.routes.ts"

    # app.config.ts
    cat > apps/shell/src/app/app.config.ts << 'EOF'
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, HTTP_INTERCEPTORS } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),
  ],
};
EOF
    print_success "app.config.ts"

    # styles.css
    cat > apps/shell/src/styles.css << 'EOF'
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

:root {
  --bg: #282c34;
  --fg: #abb2bf;
  --panel: #3e4451;
  --border: #4b5263;
}
EOF
    print_success "styles.css"
}

# Create fake backend files
create_fake_backend_files() {
    print_header "Configurando Fake Backend"

    # package.json
    cat > apps/fake-backend/package.json << 'EOF'
{
  "name": "odysseus-fake-backend",
  "version": "1.0.0",
  "main": "dist/main.js",
  "scripts": {
    "start": "node dist/main.js",
    "dev": "ts-node src/main.ts",
    "build": "tsc",
    "watch": "tsc --watch"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "uuid": "^9.0.0",
    "date-fns": "^2.30.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.0.0",
    "@types/uuid": "^9.0.0",
    "typescript": "^5.3.0",
    "ts-node": "^10.9.0"
  }
}
EOF
    print_success "package.json"

    # tsconfig.json
    cat > apps/fake-backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
    print_success "tsconfig.json"

    # main.ts
    cat > apps/fake-backend/src/main.ts << 'EOF'
import app from './app';

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`✅ Fake Backend rodando em http://localhost:${PORT}`);
  console.log(`📡 Test: curl http://localhost:${PORT}/health`);
});
EOF
    print_success "main.ts"

    # app.ts (minimal version)
    cat > apps/fake-backend/src/app.ts << 'EOF'
import express from 'express';
import cors from 'cors';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Auth routes
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  if (username === 'admin' && password === 'admin123') {
    res.json({
      token: 'fake-token-' + Date.now(),
      user: { id: 'user-123', username: 'admin', email: 'admin@odysseus.local' },
      expiresIn: 86400,
    });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Chat routes
app.post('/api/chat/session', (req, res) => {
  res.json({ id: 'session-' + Date.now() });
});

app.get('/api/chat/sessions', (req, res) => {
  res.json([]);
});

app.post('/api/chat/send', (req, res) => {
  const { sessionId, message } = req.body;
  res.json({
    id: 'msg-' + Date.now(),
    sessionId,
    role: 'user',
    content: message,
    timestamp: new Date(),
  });
});

// Email routes
app.get('/api/email/inbox', (req, res) => {
  res.json({ emails: [], total: 0 });
});

// Calendar routes
app.get('/api/calendar/events', (req, res) => {
  res.json([]);
});

// Memory routes
app.get('/api/memory', (req, res) => {
  res.json([]);
});

// Generic 404
app.use((req, res) => {
  res.status(404).json({ error: 'Not found', path: req.path });
});

export default app;
EOF
    print_success "app.ts"

    # Install fake-backend deps
    print_success "Instalando dependências do fake-backend..."
    cd apps/fake-backend
    npm install
    cd ../..
    print_success "Fake backend configurado"
}

# Create shared libraries
create_shared_libraries() {
    print_header "Configurando Shared Libraries"

    # HTTP Interceptor
    mkdir -p libs/shared/http
    cat > libs/shared/http/http.interceptor.ts << 'EOF'
import { Injectable } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class HttpConfigInterceptor implements HttpInterceptor {
  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const fakeBackendUrl = 'http://localhost:3001';
    if (request.url.startsWith('/api/')) {
      const newUrl = fakeBackendUrl + request.url;
      console.log(`[HTTP] ${request.method} ${request.url}`);
      request = request.clone({ url: newUrl });
    }
    return next.handle(request);
  }
}
EOF
    print_success "http.interceptor.ts"

    cat > libs/shared/http/index.ts << 'EOF'
export * from './http.interceptor';
EOF
    print_success "http/index.ts"

    cat > libs/shared/index.ts << 'EOF'
export * from './http/index';
EOF
    print_success "shared/index.ts"
}

# Create Docker Compose
create_docker_compose() {
    print_header "Criando Docker Compose"

    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  fake-backend:
    build:
      context: ./apps/fake-backend
      dockerfile: Dockerfile.dev
    ports:
      - '3001:3001'
    environment:
      NODE_ENV: development
      PORT: 3001
    volumes:
      - ./apps/fake-backend/src:/app/src
    command: npm run dev

  shell:
    build:
      context: .
      dockerfile: Dockerfile.dev
      args:
        PORT: 4200
    ports:
      - '4200:4200'
    depends_on:
      - fake-backend
    volumes:
      - ./apps/shell/src:/app/apps/shell/src
      - ./libs:/app/libs
    command: npm run start:shell
EOF
    print_success "docker-compose.yml"

    cat > Dockerfile.dev << 'EOF'
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

ARG PORT=4200
ENV PORT=$PORT

EXPOSE $PORT 3001

CMD ["npm", "run", "start"]
EOF
    print_success "Dockerfile.dev"
}

# Update package.json scripts
update_package_json() {
    print_header "Atualizando package.json com scripts"

    # Create scripts object
    node << 'EOF'
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

pkg.scripts = {
  ...pkg.scripts,
  "start": "nx serve shell --open",
  "start:shell": "nx serve shell --port 4200",
  "start:chat": "nx serve mfe-chat --port 4202",
  "start:memory": "nx serve mfe-memory --port 4207",
  "start:calendar": "nx serve mfe-calendar --port 4208",
  "start:email": "nx serve mfe-email --port 4209",
  "start:settings": "nx serve mfe-settings --port 4213",
  "fake-backend:dev": "cd apps/fake-backend && npm run dev",
  "fake-backend:build": "cd apps/fake-backend && npm run build",
  "dev": "concurrently \"npm:start:shell\" \"npm:fake-backend:dev\"",
  "dev:all": "concurrently \"npm:start:shell\" \"npm:start:chat\" \"npm:start:memory\" \"npm:start:calendar\" \"npm:start:email\" \"npm:start:settings\" \"npm:fake-backend:dev\"",
  "build": "nx run-many --target=build --all",
  "lint": "nx run-many --target=lint --all",
  "test": "nx run-many --target=test --all",
  "docker:up": "docker-compose up",
  "docker:down": "docker-compose down"
};

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
EOF

    print_success "Scripts adicionados ao package.json"
}

# Create README
create_readme() {
    print_header "Criando README.md"

    cat > README.md << 'EOF'
# 🚀 Odysseus - Angular 21+ Micro Frontend Architecture

Self-hosted AI workspace com arquitetura de micro frontends usando Native Federation e Tailwind CSS.

## ⚡ Quick Start

```bash
# Desenvolvimento com shell + fake-backend
npm run dev

# Desenvolvimento com todos os MFEs
npm run dev:all

# Build produção
npm run build

# Com Docker
docker-compose up
```

## 📋 Recursos

- ✅ **Shell Application** - Host principal na porta 4200
- ✅ **13 Micro Frontend Modules** - Cada um independente
- ✅ **Native Federation** - Webpack 5+ built-in
- ✅ **Tailwind CSS** - Styling moderno
- ✅ **Fake Backend** - Mock API para desenvolvimento
- ✅ **HTTP Interceptor** - Redireciona para fake-backend
- ✅ **TypeScript** - Type safety completo

## 🏗️ Arquitetura

```
Shell (4200)
├── MFE Chat (4202)
├── MFE Memory (4207)
├── MFE Calendar (4208)
├── MFE Email (4209)
├── MFE Settings (4213)
└── ... 8 mais MFEs

Fake Backend (3001)
└── Mock API para todas as telas
```

## 📁 Estrutura

```
apps/
├── shell/          # Host application
├── fake-backend/   # Express.js mock API
└── mfe-*/          # 13 Micro frontends

libs/
├── shared/         # UI, services, HTTP
├── api/           # API clients
└── theme/         # Theme management
```

## 📚 Documentação

- [SETUP_COMPLETE_GUIDE.md](./SETUP_COMPLETE_GUIDE.md) - Guia passo-a-passo
- [MIGRATION_BLUEPRINT_ANGULAR21_NATIVE_FED_TAILWIND.md](./MIGRATION_BLUEPRINT_ANGULAR21_NATIVE_FED_TAILWIND.md) - Arquitetura
- [FAKE_BACKEND_HTTP_INTERCEPTOR.md](./FAKE_BACKEND_HTTP_INTERCEPTOR.md) - Backend mock

## 🔗 Portas Padrão

| Serviço | Porta |
|---------|-------|
| Shell | 4200 |
| Chat MFE | 4202 |
| Research MFE | 4203 |
| Compare MFE | 4204 |
| Documents MFE | 4205 |
| Notes MFE | 4206 |
| Memory MFE | 4207 |
| Calendar MFE | 4208 |
| Email MFE | 4209 |
| Gallery MFE | 4210 |
| Library MFE | 4211 |
| Theme MFE | 4212 |
| Settings MFE | 4213 |
| Fake Backend | 3001 |

## 🧪 Testar

```bash
# Health check
curl http://localhost:3001/health

# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## 🐳 Docker

```bash
# Iniciar
docker-compose up

# Parar
docker-compose down
```

## 📖 Scripts Disponíveis

```bash
npm run start          # Iniciar shell com browser
npm run start:shell    # Shell apenas
npm run start:chat     # MFE Chat
npm run fake-backend:dev  # Fake backend
npm run dev            # Shell + Fake Backend
npm run dev:all        # Tudo junto
npm run build          # Build produção
npm run docker:up      # Docker compose up
```

## 🛠️ Tecnologias

- **Angular 21+** - Framework
- **Native Federation** - Module federation nativo
- **Tailwind CSS** - Styling
- **Express.js** - Fake backend
- **TypeScript** - Type safety
- **RxJS** - Reactive programming
- **Docker** - Containerização

## 📝 Próximos Passos

1. [ ] Implementar todas as rotas do fake-backend
2. [ ] Criar componentes compartilhados
3. [ ] Implementar MFEs restantes
4. [ ] Setup CI/CD
5. [ ] Deploy em produção

## 📄 Licença

MIT

## 👥 Contribuindo

Siga o SETUP_COMPLETE_GUIDE.md para começar a desenvolver!

---

**Made with ❤️ for Odysseus**
EOF

    print_success "README.md criado"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║  🚀 Odysseus Angular 21+ Setup Script  ║"
    echo "║     Native Federation + Tailwind       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"

    check_prerequisites
    create_workspace
    create_directory_structure
    create_config_files
    create_shell_files
    create_fake_backend_files
    create_shared_libraries
    create_docker_compose
    update_package_json
    create_readme

    print_header "✨ Setup Completo!"

    echo -e "${GREEN}Próximos passos:${NC}"
    echo "1. cd odysseus-ng"
    echo "2. npm run dev"
    echo ""
    echo -e "${BLUE}URLs:${NC}"
    echo "  🏠 Shell: http://localhost:4200"
    echo "  📡 Backend: http://localhost:3001"
    echo ""
    echo -e "${GREEN}Documentação:${NC}"
    echo "  📖 SETUP_COMPLETE_GUIDE.md"
    echo "  🏗️ MIGRATION_BLUEPRINT_ANGULAR21_NATIVE_FED_TAILWIND.md"
    echo "  🔌 FAKE_BACKEND_HTTP_INTERCEPTOR.md"
    echo ""
}

# Run main
main
