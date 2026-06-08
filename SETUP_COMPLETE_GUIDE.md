# 🚀 Guia Completo: Setup & Estrutura do Projeto
## Angular 21+ com Native Federation, Tailwind & Fake-Backend

---

## 📋 Índice
1. [Pré-requisitos](#pré-requisitos)
2. [Criar Workspace NX](#criar-workspace-nx)
3. [Estrutura de Diretórios](#estrutura-de-diretórios)
4. [Configurar Shell](#configurar-shell)
5. [Criar MFEs](#criar-mfes)
6. [Configurar Fake-Backend](#configurar-fake-backend)
7. [Executar Tudo](#executar-tudo)
8. [Troubleshooting](#troubleshooting)

---

## ⚙️ Pré-requisitos

```bash
# Node.js 18+
node --version

# npm 9+
npm --version

# Instalar NX CLI global (opcional mas recomendado)
npm install -g nx

# Ou usar com npx
npx nx --version
```

---

## 🎯 Criar Workspace NX

### Passo 1: Criar workspace base
```bash
# Criar novo workspace
npx create-nx-workspace odysseus-ng \
  --preset=angular \
  --packageManager=npm \
  --routing

# Entrar no diretório
cd odysseus-ng
```

### Passo 2: Instalar dependências adicionais
```bash
npm install \
  @angular/router@21 \
  @angular/forms@21 \
  @angular/common@21 \
  @angular/platform-browser@21 \
  @angular/platform-browser-dynamic@21 \
  @angular/animations@21 \
  rxjs@7 \
  tailwindcss@3 \
  postcss@8 \
  autoprefixer@10 \
  date-fns@2 \
  express@4 \
  cors@2 \
  uuid@9

npm install -D \
  @nx/angular@21 \
  @nx/webpack@21 \
  @angular-eslint/eslint-plugin@21 \
  @types/express@4 \
  @types/node@20 \
  ts-node@10 \
  typescript@5
```

---

## 📁 Estrutura de Diretórios

Execute os comandos abaixo para criar a estrutura:

```bash
# Criar pastas principais
mkdir -p apps/shell/src/app/{layout,pages}
mkdir -p apps/fake-backend/src/{routes,data,middleware}
mkdir -p libs/shared/{ui,services,http,models}
mkdir -p libs/api/{chat,email,calendar,memory,documents,notes,tasks,gallery,settings}
mkdir -p libs/theme

# MFEs
for mfe in auth chat research compare documents notes memory calendar email gallery library theme settings; do
  mkdir -p apps/mfe-${mfe}/src/app
done
```

**Resultado:**
```
odysseus-ng/
├── apps/
│   ├── shell/
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── layout/
│   │   │   │   ├── pages/
│   │   │   │   ├── app.component.ts
│   │   │   │   ├── app.routes.ts
│   │   │   │   └── app.config.ts
│   │   │   ├── main.ts
│   │   │   └── styles.css
│   │   ├── angular.json
│   │   ├── project.json
│   │   ├── webpack.config.ts
│   │   └── tsconfig.json
│   │
│   ├── fake-backend/
│   │   ├── src/
│   │   │   ├── app.ts
│   │   │   ├── main.ts
│   │   │   └── routes/
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── mfe-*/
│
├── libs/
│   ├── shared/
│   │   ├── ui/
│   │   ├── services/
│   │   ├── http/
│   │   ├── models/
│   │   └── index.ts
│   │
│   ├── api/
│   │   ├── chat/
│   │   ├── email/
│   │   └── ...
│   │
│   └── theme/
│
├── angular.json
├── nx.json
├── package.json
├── tailwind.config.js
├── postcss.config.js
├── docker-compose.yml
└── README.md
```

---

## ⚙️ Configurar Shell

### 1. Shell - project.json
```bash
cat > apps/shell/project.json << 'EOF'
{
  "projectType": "application",
  "sourceRoot": "apps/shell/src",
  "prefix": "app",
  "targets": {
    "build": {
      "executor": "@nx/angular:build",
      "outputs": ["{options.outputPath}"],
      "options": {
        "outputPath": "dist/apps/shell",
        "index": "apps/shell/src/index.html",
        "main": "apps/shell/src/main.ts",
        "polyfills": [
          "zone.js"
        ],
        "tsConfig": "apps/shell/tsconfig.app.json",
        "inlineStyleLanguage": "css",
        "assets": [
          "apps/shell/src/favicon.ico",
          "apps/shell/src/assets"
        ],
        "styles": [
          "apps/shell/src/styles.css"
        ],
        "scripts": [],
        "vendorChunk": true,
        "namedChunks": true,
        "fileReplacements": [],
        "optimization": false,
        "sourceMap": true,
        "extractLicenses": false,
        "named-chunks": true
      },
      "configurations": {
        "production": {
          "optimization": true,
          "outputHashing": "all",
          "sourceMap": false,
          "namedChunks": false,
          "aot": true,
          "extractLicenses": true,
          "vendorChunk": false
        },
        "development": {
          "optimization": false,
          "sourceMap": true,
          "namedChunks": true,
          "extractLicenses": false,
          "vendorChunk": true
        }
      },
      "defaultConfiguration": "production"
    },
    "serve": {
      "executor": "@nx/angular:dev-server",
      "configurations": {
        "production": {
          "buildTarget": "shell:build:production",
          "hmr": false
        },
        "development": {
          "buildTarget": "shell:build:development",
          "hmr": true
        }
      },
      "defaultConfiguration": "development",
      "options": {
        "port": 4200
      }
    }
  },
  "tags": []
}
EOF
```

### 2. Shell - tsconfig.json
```bash
cat > apps/shell/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.base.json",
  "files": [],
  "include": [],
  "references": [
    {
      "path": "./tsconfig.app.json"
    }
  ],
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": false,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
EOF
```

### 3. Shell - tsconfig.app.json
```bash
cat > apps/shell/tsconfig.app.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "../../dist/out-tsc/apps/shell",
    "types": [],
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true
  },
  "files": [
    "src/main.ts"
  ],
  "include": [
    "src/**/*.d.ts"
  ]
}
EOF
```

### 4. Shell - index.html
```bash
cat > apps/shell/src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Odysseus - AI Workspace</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #282c34;
      color: #abb2bf;
      font-family: system-ui, -apple-system, sans-serif;
    }
  </style>
</head>
<body>
  <app-root></app-root>
</body>
</html>
EOF
```

### 5. Shell - main.ts
```bash
cat > apps/shell/src/main.ts << 'EOF'
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig).catch(err => {
  console.error(err);
  process.exit(1);
});
EOF
```

### 6. Shell - app.component.ts
```bash
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
          <a href="/chat" class="block px-4 py-2 rounded hover:bg-odysseus-bg">💬 Chat</a>
          <a href="/memory" class="block px-4 py-2 rounded hover:bg-odysseus-bg">🧠 Memory</a>
          <a href="/calendar" class="block px-4 py-2 rounded hover:bg-odysseus-bg">📅 Calendar</a>
          <a href="/email" class="block px-4 py-2 rounded hover:bg-odysseus-bg">📧 Email</a>
          <a href="/settings" class="block px-4 py-2 rounded hover:bg-odysseus-bg">⚙️ Settings</a>
        </nav>
      </aside>

      <main class="flex-1 overflow-auto">
        <router-outlet></router-outlet>
      </main>
    </div>
  `,
  styles: [`
    :host {
      display: block;
      height: 100%;
    }
  `],
})
export class AppComponent implements OnInit {
  ngOnInit() {
    console.log('✅ Odysseus Shell loaded');
  }
}
EOF
```

### 7. Shell - app.routes.ts
```bash
cat > apps/shell/src/app/app.routes.ts << 'EOF'
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: '/chat', pathMatch: 'full' },
  {
    path: 'chat',
    loadChildren: () =>
      import('mfeChat/ChatModule').then(m => m.ChatModule),
  },
  {
    path: 'memory',
    loadChildren: () =>
      import('mfeMemory/MemoryModule').then(m => m.MemoryModule),
  },
  {
    path: 'calendar',
    loadChildren: () =>
      import('mfeCalendar/CalendarModule').then(m => m.CalendarModule),
  },
  {
    path: 'email',
    loadChildren: () =>
      import('mfeEmail/EmailModule').then(m => m.EmailModule),
  },
  {
    path: 'settings',
    loadChildren: () =>
      import('mfeSettings/SettingsModule').then(m => m.SettingsModule),
  },
];
EOF
```

### 8. Shell - app.config.ts
```bash
cat > apps/shell/src/app/app.config.ts << 'EOF'
import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, HTTP_INTERCEPTORS } from '@angular/common/http';
import { HttpConfigInterceptor } from '@odysseus/shared/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),
    {
      provide: HTTP_INTERCEPTORS,
      useClass: HttpConfigInterceptor,
      multi: true,
    },
  ],
};
EOF
```

### 9. Shell - styles.css
```bash
cat > apps/shell/src/styles.css << 'EOF'
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

:root {
  --bg: #282c34;
  --fg: #abb2bf;
  --panel: #3e4451;
  --border: #4b5263;
  --red: #e06c75;
}

@layer components {
  .odysseus-card {
    @apply bg-odysseus-panel border border-odysseus-border rounded-lg p-4 shadow-sm;
  }
}
EOF
```

---

## 🎯 Criar MFEs

### Criar MFE Chat (exemplo - repetir para outros)

```bash
# Criar estrutura
mkdir -p apps/mfe-chat/src/app/{components,services}

# project.json
cat > apps/mfe-chat/project.json << 'EOF'
{
  "projectType": "application",
  "sourceRoot": "apps/mfe-chat/src",
  "prefix": "app",
  "targets": {
    "serve": {
      "executor": "@nx/angular:dev-server",
      "options": {
        "port": 4202,
        "browserTarget": "mfe-chat:build"
      }
    },
    "build": {
      "executor": "@nx/angular:build",
      "options": {
        "outputPath": "dist/apps/mfe-chat",
        "index": "apps/mfe-chat/src/index.html",
        "main": "apps/mfe-chat/src/main.ts"
      }
    }
  }
}
EOF

# main.ts
cat > apps/mfe-chat/src/main.ts << 'EOF'
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { ChatModule } from './app/chat.module';

platformBrowserDynamic()
  .bootstrapModule(ChatModule)
  .catch(err => console.error(err));
EOF

# chat.module.ts
cat > apps/mfe-chat/src/app/chat.module.ts << 'EOF'
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { ChatComponent } from './chat.component';

@NgModule({
  imports: [
    RouterModule.forChild([
      { path: '', component: ChatComponent }
    ]),
    ChatComponent
  ]
})
export class ChatModule {}
EOF

# chat.component.ts
cat > apps/mfe-chat/src/app/chat.component.ts << 'EOF'
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-4">💬 Chat</h1>
      <div class="bg-odysseus-panel rounded-lg p-4 border border-odysseus-border">
        <p>Chat MFE loaded successfully!</p>
      </div>
    </div>
  `,
})
export class ChatComponent {}
EOF
```

---

## 🖥️ Configurar Fake-Backend

### 1. Fake-Backend - package.json
```bash
cat > apps/fake-backend/package.json << 'EOF'
{
  "name": "odysseus-fake-backend",
  "version": "1.0.0",
  "description": "Fake backend para desenvolvimento",
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

# Instalar dependências do fake-backend
cd apps/fake-backend && npm install && cd ../../
```

### 2. Fake-Backend - tsconfig.json
```bash
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
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
```

### 3. Fake-Backend - main.ts
```bash
cat > apps/fake-backend/src/main.ts << 'EOF'
import app from './app';

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`✅ Fake Backend rodando em http://localhost:${PORT}`);
  console.log(`📡 Test: curl http://localhost:${PORT}/health`);
});
EOF
```

### 4. Fake-Backend - app.ts (veja documento anterior para conteúdo completo)

---

## 🎯 Configurar Tailwind

### tailwind.config.js (raiz)
```bash
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
```

### postcss.config.js
```bash
cat > postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOF
```

---

## 📦 Configurar Shared Libraries

### libs/shared/http/http.interceptor.ts
```bash
cat > libs/shared/http/http.interceptor.ts << 'EOF'
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
} from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class HttpConfigInterceptor implements HttpInterceptor {
  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    // Redirecionar para fake backend
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
```

### libs/shared/http/index.ts
```bash
cat > libs/shared/http/index.ts << 'EOF'
export * from './http.interceptor';
EOF
```

### libs/shared/index.ts
```bash
cat > libs/shared/index.ts << 'EOF'
export * from './http/index';
EOF
```

---

## 📋 package.json (raiz) - Scripts

```bash
cat > package.json << 'EOF'
{
  "name": "odysseus-ng",
  "version": "1.0.0",
  "license": "MIT",
  "scripts": {
    "ng": "nx",
    "start": "nx serve shell --open",
    "start:shell": "nx serve shell --port 4200",
    "start:chat": "nx serve mfe-chat --port 4202",
    "start:memory": "nx serve mfe-memory --port 4207",
    "start:calendar": "nx serve mfe-calendar --port 4208",
    "start:email": "nx serve mfe-email --port 4209",
    "start:settings": "nx serve mfe-settings --port 4213",
    "fake-backend:dev": "cd apps/fake-backend && npm run dev",
    "dev": "concurrently \"npm:start:shell\" \"npm:fake-backend:dev\"",
    "dev:all": "concurrently \"npm:start:shell\" \"npm:start:chat\" \"npm:start:memory\" \"npm:start:calendar\" \"npm:start:email\" \"npm:start:settings\" \"npm:fake-backend:dev\"",
    "build": "nx run-many --target=build --all",
    "lint": "nx run-many --target=lint --all",
    "test": "nx run-many --target=test --all"
  },
  "dependencies": {
    "@angular/animations": "^21.0.0",
    "@angular/common": "^21.0.0",
    "@angular/compiler": "^21.0.0",
    "@angular/core": "^21.0.0",
    "@angular/forms": "^21.0.0",
    "@angular/platform-browser": "^21.0.0",
    "@angular/platform-browser-dynamic": "^21.0.0",
    "@angular/router": "^21.0.0",
    "rxjs": "^7.8.0",
    "tslib": "^2.6.0",
    "zone.js": "^0.14.0"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^21.0.0",
    "@angular/cli": "^21.0.0",
    "@angular/compiler-cli": "^21.0.0",
    "@nx/angular": "^21.0.0",
    "@nx/webpack": "^21.0.0",
    "autoprefixer": "^10.4.0",
    "concurrently": "^8.2.0",
    "postcss": "^8.4.0",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.3.0"
  }
}
EOF

# Instalar todas as dependências
npm install
```

---

## 🐳 Docker Compose

```bash
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
    environment:
      FAKE_BACKEND_URL: http://fake-backend:3001
    volumes:
      - ./apps/shell/src:/app/apps/shell/src
      - ./libs:/app/libs
    command: npm run start:shell

  # MFEs
  mfe-chat:
    build:
      context: .
      dockerfile: Dockerfile.dev
      args:
        PORT: 4202
    ports:
      - '4202:4202'
    depends_on:
      - fake-backend
    volumes:
      - ./apps/mfe-chat/src:/app/apps/mfe-chat/src
      - ./libs:/app/libs
    command: npm run start:chat
EOF
```

### Dockerfile.dev
```bash
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
```

---

## 🚀 Executar Tudo

### Opção 1: Tudo junto (Recomendado para começar)
```bash
npm run dev
```

Isso vai abrir:
- 🏠 **Shell**: http://localhost:4200
- 🖥️ **Fake Backend**: http://localhost:3001

### Opção 2: Com todos os MFEs
```bash
npm run dev:all
```

Portas:
- Shell: 4200
- Chat MFE: 4202
- Memory MFE: 4207
- Calendar MFE: 4208
- Email MFE: 4209
- Settings MFE: 4213
- Fake Backend: 3001

### Opção 3: Rodar shell apenas
```bash
npm run start:shell
```

### Opção 4: Com Docker Compose
```bash
docker-compose up
```

---

## ✅ Verificar se tudo está funcionando

### 1. Health Check do Backend
```bash
curl http://localhost:3001/health
# Response: {"status":"ok","timestamp":"..."}
```

### 2. Login
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 3. Criar sessão de chat
```bash
curl -X POST http://localhost:3001/api/chat/session \
  -H "Authorization: Bearer token-xxx"
```

### 4. No navegador
```
http://localhost:4200
```

---

## 📝 Criar novo MFE (Template)

```bash
#!/bin/bash
MFE_NAME=$1
PORT=$2

# Criar estrutura
mkdir -p apps/mfe-${MFE_NAME}/src/app

# project.json
cat > apps/mfe-${MFE_NAME}/project.json << EOF
{
  "projectType": "application",
  "sourceRoot": "apps/mfe-${MFE_NAME}/src",
  "targets": {
    "serve": {
      "executor": "@nx/angular:dev-server",
      "options": { "port": ${PORT} }
    },
    "build": {
      "executor": "@nx/angular:build",
      "options": {
        "outputPath": "dist/apps/mfe-${MFE_NAME}",
        "main": "apps/mfe-${MFE_NAME}/src/main.ts"
      }
    }
  }
}
EOF

# main.ts
cat > apps/mfe-${MFE_NAME}/src/main.ts << 'EOF'
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .catch(err => console.error(err));
EOF

echo "✅ MFE ${MFE_NAME} criado na porta ${PORT}"
```

Use assim:
```bash
chmod +x create-mfe.sh
./create-mfe.sh compare 4204
./create-mfe.sh research 4203
```

---

## 🔧 Troubleshooting

### Problema: "Port already in use"
```bash
# Verificar qual processo está usando a porta
lsof -i :4200

# Matar processo (macOS/Linux)
kill -9 <PID>

# Windows
netstat -ano | findstr :4200
taskkill /PID <PID> /F
```

### Problema: "Cannot find module @odysseus/shared/http"
```bash
# Reconstruir path mappings
nx reset

# Ou limpar cache
rm -rf node_modules
npm install
```

### Problema: Fake Backend não conecta
```bash
# Verificar se está rodando
curl http://localhost:3001/health

# Se erro de CORS, verificar app.ts (já está configurado)

# Logs do fake backend
npm run fake-backend:dev
```

### Problema: Tailwind não carrega estilos
```bash
# Rebuild CSS
npm run dev

# Ou forçar reload do navegador (Cmd+Shift+R / Ctrl+Shift+R)
```

---

## 📚 Próximos Passos

1. ✅ Copiar todos os documentos anteriores para o projeto
2. ✅ Implementar todas as rotas do fake-backend
3. ✅ Criar componentes Tailwind compartilhados
4. ✅ Implement MFEs restantes
5. ✅ Setup CI/CD
6. ✅ Deploy (Vercel/Netlify/AWS)

---

## 📖 Referências Rápidas

```bash
# Servir aplicação
nx serve shell

# Build produção
nx build shell --prod

# Gerar novo componente
nx generate @nx/angular:component --project=shell --name=my-component

# Gerar nova lib
nx generate @nx/angular:library --name=my-lib

# Rodar testes
nx test shell

# Lint
nx lint shell
```

---

**Status**: Pronto para Codificar! 🚀
**Tempo Estimado**: 30 min para setup completo
