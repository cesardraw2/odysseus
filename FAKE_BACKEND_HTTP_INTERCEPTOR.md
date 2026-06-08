# API REST Fake-Backend & HTTP Interceptor
## Para Desenvolvimento do Frontend Angular 21+ com Tailwind

---

## 📋 Overview

Este documento detalha a implementação de:

1. **Fake-Backend REST API** (Express.js ou JSON-Server)
2. **HTTP Interceptor** para redirecionar requisições
3. **Mock Data** para todas as telas
4. **Ambiente de Desenvolvimento** isolado

---

## 🏗️ Arquitetura

```
odysseus-ng/
├── apps/
│   ├── fake-backend/              # ← NOVO: Servidor fake
│   │   ├── src/
│   │   │   ├── main.ts
│   │   │   ├── app.ts
│   │   │   ├── routes/
│   │   │   │   ├── auth.routes.ts
│   │   │   │   ├── chat.routes.ts
│   │   │   │   ├── email.routes.ts
│   │   │   │   ├── calendar.routes.ts
│   │   │   │   ├── memory.routes.ts
│   │   │   │   ├── documents.routes.ts
│   │   │   │   ├── notes.routes.ts
│   │   │   │   ├── gallery.routes.ts
│   │   │   │   ├── tasks.routes.ts
│   │   │   │   ├── settings.routes.ts
│   │   │   │   └── index.ts
│   │   ├── data/
│   │   │   ├── db.json              # Mock data
│   │   │   └── seed.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── shell/
│   │   └── src/
│   │       ├── app/
│   │       │   ├── app.component.ts
│   │       │   └── app.config.ts
│   │       └── styles.css
│   │
│   └── mfe-**/
│
├── libs/
│   ├── shared/
│   │   ├── http/
│   │   │   ├── http.interceptor.ts      # ← NOVO: Interceptor
│   │   │   ├── http-client.config.ts
│   │   │   └── fake-backend.config.ts
│   │   ├── ui/
│   │   ├── services/
│   │   └── models/
│   │
│   └── api/
│       ├── chat/
│       ├── email/
│       ├── calendar/
│       └── ...
│
└── package.json
```

---

## 🎯 Fase 1: Fake-Backend com Express.js

### apps/fake-backend/package.json
```json
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
```

### apps/fake-backend/src/main.ts
```typescript
import app from './app';

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`🚀 Fake Backend rodando em http://localhost:${PORT}`);
  console.log(`📡 Endpoint base: /api`);
});
```

### apps/fake-backend/src/app.ts
```typescript
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

// Routes
import authRoutes from './routes/auth.routes';
import chatRoutes from './routes/chat.routes';
import emailRoutes from './routes/email.routes';
import calendarRoutes from './routes/calendar.routes';
import memoryRoutes from './routes/memory.routes';
import documentsRoutes from './routes/documents.routes';
import notesRoutes from './routes/notes.routes';
import tasksRoutes from './routes/tasks.routes';
import galleryRoutes from './routes/gallery.routes';
import settingsRoutes from './routes/settings.routes';

const app: Express = express();

// Middleware
app.use(cors({
  origin: [
    'http://localhost:4200',
    'http://localhost:4201',
    'http://localhost:4202',
    'http://localhost:4203',
    'http://localhost:4204',
    'http://localhost:4205',
    'http://localhost:4206',
    'http://localhost:4207',
    'http://localhost:4208',
    'http://localhost:4209',
    'http://localhost:4210',
    'http://localhost:4211',
    'http://localhost:4212',
    'http://localhost:4213',
  ],
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req: Request, res: Response, next: NextFunction) => {
  const requestId = uuidv4().slice(0, 8);
  console.log(`[${requestId}] ${req.method} ${req.path}`);
  res.setHeader('X-Request-ID', requestId);
  next();
});

// Auth middleware (fake)
app.use((req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  // Skip auth para login
  if (req.path.includes('/auth/login') || req.path.includes('/auth/register')) {
    return next();
  }

  // Aceitar qualquer token ou cookie de sessão
  if (token || req.headers.cookie?.includes('session')) {
    res.locals.userId = 'user-123';
    res.locals.username = 'admin';
    return next();
  }

  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/email', emailRoutes);
app.use('/api/calendar', calendarRoutes);
app.use('/api/memory', memoryRoutes);
app.use('/api/documents', documentsRoutes);
app.use('/api/notes', notesRoutes);
app.use('/api/tasks', tasksRoutes);
app.use('/api/gallery', galleryRoutes);
app.use('/api/settings', settingsRoutes);

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method,
  });
});

// Error handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  console.error('❌ Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    status: err.status || 500,
  });
});

export default app;
```

---

## 🔐 Auth Routes

### apps/fake-backend/src/routes/auth.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

interface User {
  id: string;
  username: string;
  email: string;
  password: string;
  avatar?: string;
  created_at: Date;
}

interface LoginRequest {
  username: string;
  password: string;
}

interface LoginResponse {
  token: string;
  user: Omit<User, 'password'>;
  expiresIn: number;
}

// Mock database
const users: User[] = [
  {
    id: 'user-123',
    username: 'admin',
    email: 'admin@odysseus.local',
    password: 'admin123',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
    created_at: new Date('2024-01-01'),
  },
  {
    id: 'user-456',
    username: 'developer',
    email: 'dev@odysseus.local',
    password: 'dev123',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=developer',
    created_at: new Date('2024-01-05'),
  },
];

// Login
router.post('/login', (req: Request, res: Response) => {
  const { username, password }: LoginRequest = req.body;

  if (!username || !password) {
    return res.status(400).json({
      error: 'Username and password are required',
    });
  }

  const user = users.find(u => u.username === username && u.password === password);

  if (!user) {
    return res.status(401).json({
      error: 'Invalid credentials',
    });
  }

  const token = `token-${uuidv4()}`;
  const { password: _, ...userWithoutPassword } = user;

  res.json({
    token,
    user: userWithoutPassword,
    expiresIn: 86400, // 24 horas
  } as LoginResponse);
});

// Register
router.post('/register', (req: Request, res: Response) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({
      error: 'Username, email and password are required',
    });
  }

  if (users.some(u => u.username === username || u.email === email)) {
    return res.status(409).json({
      error: 'User already exists',
    });
  }

  const newUser: User = {
    id: `user-${uuidv4().slice(0, 8)}`,
    username,
    email,
    password,
    avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${username}`,
    created_at: new Date(),
  };

  users.push(newUser);

  const token = `token-${uuidv4()}`;
  const { password: _, ...userWithoutPassword } = newUser;

  res.status(201).json({
    token,
    user: userWithoutPassword,
    expiresIn: 86400,
  } as LoginResponse);
});

// Logout
router.post('/logout', (req: Request, res: Response) => {
  res.json({ message: 'Logged out successfully' });
});

// Current user
router.get('/me', (req: Request, res: Response) => {
  const user = users.find(u => u.id === 'user-123');
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  const { password: _, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

export default router;
```

---

## 💬 Chat Routes

### apps/fake-backend/src/routes/chat.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { addMinutes } from 'date-fns';

const router = Router();

interface ChatMessage {
  id: string;
  sessionId: string;
  role: 'user' | 'assistant';
  content: string;
  tokens?: number;
  model?: string;
  timestamp: Date;
}

interface ChatSession {
  id: string;
  userId: string;
  title: string;
  created_at: Date;
  updated_at: Date;
  messageCount: number;
}

// Mock data
const sessions: Map<string, ChatSession> = new Map();
const messages: Map<string, ChatMessage[]> = new Map();

// Seed initial data
const seedSession = (): ChatSession => {
  const sessionId = `session-${uuidv4().slice(0, 8)}`;
  const session: ChatSession = {
    id: sessionId,
    userId: 'user-123',
    title: 'New Chat',
    created_at: new Date(),
    updated_at: new Date(),
    messageCount: 0,
  };
  sessions.set(sessionId, session);
  messages.set(sessionId, []);
  return session;
};

// Pré-popular com uma sessão
if (sessions.size === 0) {
  seedSession();
}

// Get all sessions
router.get('/sessions', (req: Request, res: Response) => {
  const userSessions = Array.from(sessions.values()).filter(
    s => s.userId === res.locals.userId
  );
  res.json(userSessions);
});

// Create new session
router.post('/session', (req: Request, res: Response) => {
  const session = seedSession();
  res.status(201).json(session);
});

// Get conversation
router.get('/conversation/:sessionId', (req: Request, res: Response) => {
  const { sessionId } = req.params;
  const sessionMessages = messages.get(sessionId) || [];
  res.json(sessionMessages);
});

// Send message
router.post('/send', (req: Request, res: Response) => {
  const { sessionId, message, model = 'gpt-4' } = req.body;

  if (!sessionId || !message) {
    return res.status(400).json({ error: 'sessionId and message are required' });
  }

  if (!messages.has(sessionId)) {
    return res.status(404).json({ error: 'Session not found' });
  }

  const session = sessions.get(sessionId);
  if (!session) {
    return res.status(404).json({ error: 'Session not found' });
  }

  // Adicionar mensagem do usuário
  const userMsg: ChatMessage = {
    id: `msg-${uuidv4().slice(0, 8)}`,
    sessionId,
    role: 'user',
    content: message,
    tokens: Math.ceil(message.length / 4),
    model,
    timestamp: new Date(),
  };

  messages.get(sessionId)!.push(userMsg);

  // Simular resposta do AI
  setTimeout(() => {
    const responses: Record<string, string> = {
      'hello': 'Hello! How can I help you today?',
      'how are you': "I'm doing well, thank you for asking! How can I assist you?",
      'what is odysseus': 'Odysseus is a self-hosted AI workspace with chat, agents, deep research, and more.',
      'default': 'That\'s an interesting question. Let me think about that... I\'m here to help with any queries you might have!',
    };

    const lowerMsg = message.toLowerCase();
    let responseText = responses['default'];

    for (const [key, value] of Object.entries(responses)) {
      if (lowerMsg.includes(key)) {
        responseText = value;
        break;
      }
    }

    const aiMsg: ChatMessage = {
      id: `msg-${uuidv4().slice(0, 8)}`,
      sessionId,
      role: 'assistant',
      content: responseText,
      tokens: Math.ceil(responseText.length / 4),
      model,
      timestamp: new Date(),
    };

    messages.get(sessionId)!.push(aiMsg);

    // Atualizar session
    if (session) {
      session.updated_at = new Date();
      session.messageCount = messages.get(sessionId)!.length;
    }
  }, 500 + Math.random() * 1500);

  // Retornar mensagem do usuário
  res.status(201).json(userMsg);
});

// Rename session
router.patch('/session/:sessionId', (req: Request, res: Response) => {
  const { sessionId } = req.params;
  const { title } = req.body;

  const session = sessions.get(sessionId);
  if (!session) {
    return res.status(404).json({ error: 'Session not found' });
  }

  session.title = title || session.title;
  session.updated_at = new Date();

  res.json(session);
});

// Delete session
router.delete('/session/:sessionId', (req: Request, res: Response) => {
  const { sessionId } = req.params;

  if (!sessions.has(sessionId)) {
    return res.status(404).json({ error: 'Session not found' });
  }

  sessions.delete(sessionId);
  messages.delete(sessionId);

  res.json({ message: 'Session deleted' });
});

export default router;
```

---

## 📧 Email Routes

### apps/fake-backend/src/routes/email.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { subDays, subHours } from 'date-fns';

const router = Router();

interface Email {
  id: string;
  from: string;
  to: string;
  subject: string;
  body: string;
  read: boolean;
  starred: boolean;
  timestamp: Date;
  attachments?: string[];
}

// Mock data
const emails: Email[] = [
  {
    id: `email-${uuidv4().slice(0, 8)}`,
    from: 'support@odysseus.ai',
    to: 'admin@odysseus.local',
    subject: 'Welcome to Odysseus',
    body: 'Thank you for using Odysseus! Here\'s how to get started...',
    read: true,
    starred: false,
    timestamp: subDays(new Date(), 3),
  },
  {
    id: `email-${uuidv4().slice(0, 8)}`,
    from: 'team@odysseus.ai',
    to: 'admin@odysseus.local',
    subject: 'New features released',
    body: 'We\'ve added deep research, model comparison, and more!',
    read: false,
    starred: true,
    timestamp: subDays(new Date(), 1),
  },
  {
    id: `email-${uuidv4().slice(0, 8)}`,
    from: 'notifications@odysseus.ai',
    to: 'admin@odysseus.local',
    subject: 'Your scheduled task completed',
    body: 'The scheduled task you set up has completed successfully.',
    read: false,
    starred: false,
    timestamp: subHours(new Date(), 2),
  },
];

// Get inbox
router.get('/inbox', (req: Request, res: Response) => {
  const skip = parseInt(req.query.skip as string) || 0;
  const limit = parseInt(req.query.limit as string) || 20;

  const paginated = emails.slice(skip, skip + limit);
  res.json({
    emails: paginated,
    total: emails.length,
    skip,
    limit,
  });
});

// Get email
router.get('/:id', (req: Request, res: Response) => {
  const email = emails.find(e => e.id === req.params.id);
  if (!email) {
    return res.status(404).json({ error: 'Email not found' });
  }
  res.json(email);
});

// Send email
router.post('/send', (req: Request, res: Response) => {
  const { to, subject, body } = req.body;

  if (!to || !subject || !body) {
    return res.status(400).json({ error: 'to, subject, and body are required' });
  }

  const newEmail: Email = {
    id: `email-${uuidv4().slice(0, 8)}`,
    from: 'admin@odysseus.local',
    to,
    subject,
    body,
    read: true,
    starred: false,
    timestamp: new Date(),
  };

  emails.unshift(newEmail);

  res.status(201).json(newEmail);
});

// Mark as read
router.patch('/:id/read', (req: Request, res: Response) => {
  const email = emails.find(e => e.id === req.params.id);
  if (!email) {
    return res.status(404).json({ error: 'Email not found' });
  }
  email.read = true;
  res.json(email);
});

// Toggle star
router.patch('/:id/star', (req: Request, res: Response) => {
  const email = emails.find(e => e.id === req.params.id);
  if (!email) {
    return res.status(404).json({ error: 'Email not found' });
  }
  email.starred = !email.starred;
  res.json(email);
});

// Delete email
router.delete('/:id', (req: Request, res: Response) => {
  const index = emails.findIndex(e => e.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Email not found' });
  }
  emails.splice(index, 1);
  res.json({ message: 'Email deleted' });
});

export default router;
```

---

## 📅 Calendar Routes

### apps/fake-backend/src/routes/calendar.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { addDays, addHours } from 'date-fns';

const router = Router();

interface CalendarEvent {
  id: string;
  title: string;
  description: string;
  start: Date;
  end: Date;
  allDay: boolean;
  reminders: number[];
  location?: string;
  attendees?: string[];
}

// Mock data
const events: CalendarEvent[] = [
  {
    id: `event-${uuidv4().slice(0, 8)}`,
    title: 'Team Standup',
    description: 'Daily sync with the team',
    start: addHours(new Date(), 2),
    end: addHours(new Date(), 2.5),
    allDay: false,
    reminders: [15],
    location: 'Meeting Room A',
  },
  {
    id: `event-${uuidv4().slice(0, 8)}`,
    title: 'Project Deadline',
    description: 'Finish Odysseus migration',
    start: addDays(new Date(), 7),
    end: addDays(new Date(), 7),
    allDay: true,
    reminders: [1440],
  },
  {
    id: `event-${uuidv4().slice(0, 8)}`,
    title: 'Client Meeting',
    description: 'Discuss new features',
    start: addDays(new Date(), 3),
    end: addDays(new Date(), 3),
    allDay: false,
    reminders: [30],
    attendees: ['client@example.com'],
  },
];

// Get events
router.get('/events', (req: Request, res: Response) => {
  const startDate = req.query.start ? new Date(req.query.start as string) : new Date();
  const endDate = req.query.end ? new Date(req.query.end as string) : addDays(new Date(), 30);

  const filtered = events.filter(
    e => new Date(e.start) >= startDate && new Date(e.start) <= endDate
  );

  res.json(filtered);
});

// Create event
router.post('/events', (req: Request, res: Response) => {
  const { title, description, start, end, allDay, location, attendees } = req.body;

  if (!title || !start || !end) {
    return res.status(400).json({ error: 'title, start, and end are required' });
  }

  const newEvent: CalendarEvent = {
    id: `event-${uuidv4().slice(0, 8)}`,
    title,
    description,
    start: new Date(start),
    end: new Date(end),
    allDay: allDay || false,
    reminders: [15],
    location,
    attendees,
  };

  events.push(newEvent);
  res.status(201).json(newEvent);
});

// Update event
router.patch('/events/:id', (req: Request, res: Response) => {
  const event = events.find(e => e.id === req.params.id);
  if (!event) {
    return res.status(404).json({ error: 'Event not found' });
  }

  Object.assign(event, req.body);
  res.json(event);
});

// Delete event
router.delete('/events/:id', (req: Request, res: Response) => {
  const index = events.findIndex(e => e.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Event not found' });
  }
  events.splice(index, 1);
  res.json({ message: 'Event deleted' });
});

export default router;
```

---

## 🧠 Memory Routes

### apps/fake-backend/src/routes/memory.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

interface Memory {
  id: string;
  category: string;
  content: string;
  uses: number;
  created_at: Date;
  updated_at: Date;
}

interface Skill {
  id: string;
  title: string;
  problem: string;
  solution: string;
  tags: string[];
  confidence: number;
  uses: number;
  status: 'draft' | 'published';
  created_at: Date;
}

// Mock data
const memories: Memory[] = [
  {
    id: `memory-${uuidv4().slice(0, 8)}`,
    category: 'preferences',
    content: 'User prefers concise, direct responses',
    uses: 24,
    created_at: new Date('2024-01-01'),
    updated_at: new Date('2024-01-15'),
  },
  {
    id: `memory-${uuidv4().slice(0, 8)}`,
    category: 'context',
    content: 'Currently working on Odysseus Angular migration',
    uses: 8,
    created_at: new Date('2024-01-10'),
    updated_at: new Date('2024-01-12'),
  },
];

const skills: Skill[] = [
  {
    id: `skill-${uuidv4().slice(0, 8)}`,
    title: 'setup-angular-federation',
    problem: 'How to set up Native Federation in Angular 21+',
    solution: 'Install @nx/angular, create webpack.config.ts with getNativeFederationConfig, add to angular.json',
    tags: ['angular', 'federation', 'webpack'],
    confidence: 92,
    uses: 3,
    status: 'published',
    created_at: new Date('2024-01-05'),
  },
  {
    id: `skill-${uuidv4().slice(0, 8)}`,
    title: 'tailwind-custom-theme',
    problem: 'How to create custom Tailwind themes',
    solution: 'Use CSS variables in tailwind.config.js, create preset files, use @layer directives',
    tags: ['tailwind', 'css', 'styling'],
    confidence: 85,
    uses: 5,
    status: 'published',
    created_at: new Date('2024-01-08'),
  },
];

// Get memories
router.get('/', (req: Request, res: Response) => {
  const search = req.query.search as string;
  const category = req.query.category as string;

  let filtered = memories;

  if (search) {
    filtered = filtered.filter(m =>
      m.content.toLowerCase().includes(search.toLowerCase())
    );
  }

  if (category) {
    filtered = filtered.filter(m => m.category === category);
  }

  res.json(filtered);
});

// Create memory
router.post('/', (req: Request, res: Response) => {
  const { content, category = 'general' } = req.body;

  if (!content) {
    return res.status(400).json({ error: 'content is required' });
  }

  const newMemory: Memory = {
    id: `memory-${uuidv4().slice(0, 8)}`,
    category,
    content,
    uses: 0,
    created_at: new Date(),
    updated_at: new Date(),
  };

  memories.push(newMemory);
  res.status(201).json(newMemory);
});

// Update memory
router.patch('/:id', (req: Request, res: Response) => {
  const memory = memories.find(m => m.id === req.params.id);
  if (!memory) {
    return res.status(404).json({ error: 'Memory not found' });
  }

  memory.content = req.body.content || memory.content;
  memory.category = req.body.category || memory.category;
  memory.updated_at = new Date();

  res.json(memory);
});

// Delete memory
router.delete('/:id', (req: Request, res: Response) => {
  const index = memories.findIndex(m => m.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Memory not found' });
  }
  memories.splice(index, 1);
  res.json({ message: 'Memory deleted' });
});

// ========== Skills ==========

// Get skills
router.get('/skills', (req: Request, res: Response) => {
  res.json(skills);
});

// Create skill
router.post('/skills', (req: Request, res: Response) => {
  const { title, problem, solution, tags = [] } = req.body;

  if (!title || !problem || !solution) {
    return res.status(400).json({ error: 'title, problem, and solution are required' });
  }

  const newSkill: Skill = {
    id: `skill-${uuidv4().slice(0, 8)}`,
    title,
    problem,
    solution,
    tags,
    confidence: 50,
    uses: 0,
    status: 'draft',
    created_at: new Date(),
  };

  skills.push(newSkill);
  res.status(201).json(newSkill);
});

// Publish skill
router.patch('/skills/:id/publish', (req: Request, res: Response) => {
  const skill = skills.find(s => s.id === req.params.id);
  if (!skill) {
    return res.status(404).json({ error: 'Skill not found' });
  }

  skill.status = 'published';
  res.json(skill);
});

// Delete skill
router.delete('/skills/:id', (req: Request, res: Response) => {
  const index = skills.findIndex(s => s.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Skill not found' });
  }
  skills.splice(index, 1);
  res.json({ message: 'Skill deleted' });
});

export default router;
```

---

## 📄 Documentos, Notas e Tarefas (Resumido)

### apps/fake-backend/src/routes/documents.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

interface Document {
  id: string;
  title: string;
  content: string;
  type: 'markdown' | 'html' | 'csv';
  created_at: Date;
  updated_at: Date;
}

const documents: Document[] = [];

router.get('/', (req: Request, res: Response) => res.json(documents));

router.post('/', (req: Request, res: Response) => {
  const { title, content, type = 'markdown' } = req.body;
  const doc: Document = {
    id: `doc-${uuidv4().slice(0, 8)}`,
    title,
    content,
    type,
    created_at: new Date(),
    updated_at: new Date(),
  };
  documents.push(doc);
  res.status(201).json(doc);
});

router.get('/:id', (req: Request, res: Response) => {
  const doc = documents.find(d => d.id === req.params.id);
  res.json(doc || { error: 'Not found' });
});

router.patch('/:id', (req: Request, res: Response) => {
  const doc = documents.find(d => d.id === req.params.id);
  if (doc) {
    doc.content = req.body.content || doc.content;
    doc.updated_at = new Date();
  }
  res.json(doc);
});

router.delete('/:id', (req: Request, res: Response) => {
  const idx = documents.findIndex(d => d.id === req.params.id);
  if (idx > -1) documents.splice(idx, 1);
  res.json({ success: true });
});

export default router;
```

### apps/fake-backend/src/routes/notes.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

interface Note {
  id: string;
  title: string;
  content: string;
  pinned: boolean;
  created_at: Date;
  updated_at: Date;
}

interface Task {
  id: string;
  title: string;
  completed: boolean;
  dueDate?: Date;
  created_at: Date;
}

const notes: Note[] = [];
const tasks: Task[] = [];

// Notes CRUD
router.get('/notes', (req: Request, res: Response) => res.json(notes));
router.post('/notes', (req: Request, res: Response) => {
  const note: Note = {
    id: `note-${uuidv4().slice(0, 8)}`,
    ...req.body,
    created_at: new Date(),
    updated_at: new Date(),
  };
  notes.push(note);
  res.status(201).json(note);
});

// Tasks CRUD
router.get('/tasks', (req: Request, res: Response) => res.json(tasks));
router.post('/tasks', (req: Request, res: Response) => {
  const task: Task = {
    id: `task-${uuidv4().slice(0, 8)}`,
    ...req.body,
    created_at: new Date(),
  };
  tasks.push(task);
  res.status(201).json(task);
});

export default router;
```

### apps/fake-backend/src/routes/tasks.routes.ts
```typescript
import { Router, Request, Response } from 'express';

const router = Router();

// Redirecionar para notes.routes.ts ou implementar separadamente
router.get('/activity', (req: Request, res: Response) => {
  res.json({
    activity: [],
    lastUpdate: new Date(),
  });
});

export default router;
```

### apps/fake-backend/src/routes/gallery.routes.ts
```typescript
import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

interface Image {
  id: string;
  url: string;
  title: string;
  description: string;
  uploaded_at: Date;
}

const images: Image[] = [];

router.get('/', (req: Request, res: Response) => res.json(images));

router.post('/', (req: Request, res: Response) => {
  const img: Image = {
    id: `img-${uuidv4().slice(0, 8)}`,
    url: req.body.url || `https://via.placeholder.com/300?text=${req.body.title}`,
    title: req.body.title || 'Untitled',
    description: req.body.description || '',
    uploaded_at: new Date(),
  };
  images.push(img);
  res.status(201).json(img);
});

export default router;
```

### apps/fake-backend/src/routes/settings.routes.ts
```typescript
import { Router, Request, Response } from 'express';

const router = Router();

interface Settings {
  theme: string;
  notifications: boolean;
  autoMemory: boolean;
  autoSkills: boolean;
}

let settings: Settings = {
  theme: 'dark',
  notifications: true,
  autoMemory: true,
  autoSkills: false,
};

router.get('/', (req: Request, res: Response) => res.json(settings));

router.patch('/', (req: Request, res: Response) => {
  settings = { ...settings, ...req.body };
  res.json(settings);
});

export default router;
```

### apps/fake-backend/src/routes/index.ts
```typescript
export { default as authRoutes } from './auth.routes';
export { default as chatRoutes } from './chat.routes';
export { default as emailRoutes } from './email.routes';
export { default as calendarRoutes } from './calendar.routes';
export { default as memoryRoutes } from './memory.routes';
export { default as documentsRoutes } from './documents.routes';
export { default as notesRoutes } from './notes.routes';
export { default as tasksRoutes } from './tasks.routes';
export { default as galleryRoutes } from './gallery.routes';
export { default as settingsRoutes } from './settings.routes';
```

---

## 🔄 HTTP Interceptor

### libs/shared/http/http.interceptor.ts
```typescript
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse,
} from '@angular/common/http';
import { Observable, throwError, BehaviorSubject } from 'rxjs';
import { catchError, filter, take, switchMap } from 'rxjs/operators';
import { AuthService } from '@odysseus/api';

@Injectable()
export class HttpConfigInterceptor implements HttpInterceptor {
  private isRefreshing = false;
  private refreshTokenSubject: BehaviorSubject<any> = new BehaviorSubject<any>(
    null
  );

  constructor(private authService: AuthService) {}

  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    // Redirecionar para fake backend se em desenvolvimento
    if (this.isFakeDev()) {
      request = this.redirectToFakeBackend(request);
    }

    // Adicionar token se existir
    const token = this.authService.getToken();
    if (token && !request.headers.has('Authorization')) {
      request = request.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`,
        },
      });
    }

    // Adicionar headers padrão
    if (!request.headers.has('Content-Type')) {
      request = request.clone({
        setHeaders: {
          'Content-Type': 'application/json',
        },
      });
    }

    request = request.clone({
      setHeaders: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    });

    return next.handle(request).pipe(
      catchError(error => {
        if (error instanceof HttpErrorResponse) {
          switch (error.status) {
            case 401:
              return this.handle401Error(request, next);

            case 403:
              return throwError(() => ({
                message: 'Access forbidden',
                status: 403,
              }));

            case 404:
              console.warn('Resource not found:', request.url);
              break;

            case 500:
              console.error('Server error:', error);
              break;
          }
        }

        return throwError(() => error);
      })
    );
  }

  /**
   * Verifica se está em modo desenvolvimento com fake backend
   */
  private isFakeDev(): boolean {
    const environment = (window as any)['__ENVIRONMENT__'] || 'production';
    return environment === 'development' && !this.isRealBackendAvailable();
  }

  /**
   * Verifica se o backend real está disponível
   */
  private isRealBackendAvailable(): boolean {
    // Verificar localStorage ou variável de ambiente
    return localStorage.getItem('USE_REAL_BACKEND') === 'true';
  }

  /**
   * Redireciona URLs de API para fake backend
   */
  private redirectToFakeBackend(request: HttpRequest<any>): HttpRequest<any> {
    const fakeBackendUrl = 'http://localhost:3001';

    // Apenas redirecionar rotas /api/*
    if (request.url.startsWith('/api/')) {
      const newUrl = fakeBackendUrl + request.url;
      console.log(`[Fake Backend] ${request.method} ${request.url} → ${newUrl}`);

      return request.clone({
        url: newUrl,
      });
    }

    return request;
  }

  /**
   * Handle 401 Unauthorized
   */
  private handle401Error(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    if (!this.isRefreshing) {
      this.isRefreshing = true;
      this.refreshTokenSubject.next(null);

      return this.authService.refreshToken().pipe(
        switchMap((response: any) => {
          this.isRefreshing = false;
          this.refreshTokenSubject.next(response.token);
          return next.handle(this.addToken(request, response.token));
        }),
        catchError(() => {
          this.isRefreshing = false;
          this.authService.logout();
          return throwError(() => ({ message: 'Unauthorized' }));
        })
      );
    } else {
      return this.refreshTokenSubject.pipe(
        filter(token => token != null),
        take(1),
        switchMap(token => {
          return next.handle(this.addToken(request, token));
        })
      );
    }
  }

  /**
   * Adiciona token de autenticação
   */
  private addToken(
    request: HttpRequest<any>,
    token: string
  ): HttpRequest<any> {
    return request.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
      },
    });
  }
}
```

### libs/shared/http/http-client.config.ts
```typescript
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { HttpConfigInterceptor } from './http.interceptor';

export const httpClientProviders = [
  HttpClientModule,
  {
    provide: HTTP_INTERCEPTORS,
    useClass: HttpConfigInterceptor,
    multi: true,
  },
];
```

### libs/shared/http/fake-backend.config.ts
```typescript
/**
 * Configurações do Fake Backend
 */
export const FAKE_BACKEND_CONFIG = {
  // Fake backend URL
  baseUrl: 'http://localhost:3001',

  // Simular latência de rede
  simulateDelay: 200,

  // Endpoints que devem usar fake backend
  routes: [
    '/api/auth/*',
    '/api/chat/*',
    '/api/email/*',
    '/api/calendar/*',
    '/api/memory/*',
    '/api/documents/*',
    '/api/notes/*',
    '/api/tasks/*',
    '/api/gallery/*',
    '/api/settings/*',
  ],

  // Modo forçado (ignorar detecção automática)
  forceUseFakeBackend: false,
};

/**
 * Habilitar/desabilitar fake backend via console
 */
if (typeof window !== 'undefined') {
  (window as any).toggleFakeBackend = (use: boolean) => {
    if (use) {
      localStorage.setItem('USE_REAL_BACKEND', 'false');
      console.log('✅ Fake Backend ATIVADO');
    } else {
      localStorage.setItem('USE_REAL_BACKEND', 'true');
      console.log('✅ Real Backend ATIVADO');
    }
    location.reload();
  };

  console.log('%cFake Backend Status', 'font-weight: bold; font-size: 14px;');
  console.log('Use: toggleFakeBackend(true) ou toggleFakeBackend(false)');
}
```

---

## 🧭 Integração no Shell

### apps/shell/src/app/app.config.ts
```typescript
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
```

---

## 🚀 Scripts & Docker

### package.json (adição)
```json
{
  "scripts": {
    "fake-backend:dev": "cd apps/fake-backend && npm run dev",
    "fake-backend:build": "cd apps/fake-backend && npm run build",
    "fake-backend:start": "cd apps/fake-backend && npm start",
    "dev": "concurrently \"npm:start:shell\" \"npm:fake-backend:dev\"",
    "dev:all": "concurrently \"npm:start:all\" \"npm:fake-backend:dev\""
  }
}
```

### docker-compose.yml (atualizado)
```yaml
version: '3.8'

services:
  fake-backend:
    build:
      context: ./apps/fake-backend
      dockerfile: Dockerfile
    ports:
      - '3001:3001'
    environment:
      NODE_ENV: development
      PORT: 3001
    volumes:
      - ./apps/fake-backend/src:/app/src

  shell:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        PORT: 4200
    ports:
      - '4200:4200'
    depends_on:
      - fake-backend
    environment:
      FAKE_BACKEND_URL: http://fake-backend:3001

  # MFEs...
```

### apps/fake-backend/Dockerfile
```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

EXPOSE 3001

CMD ["npm", "start"]
```

---

## 📊 Como Usar

### 1. **Iniciar Fake Backend**
```bash
npm run fake-backend:dev
# ou
npm run dev
```

### 2. **Verificar Status**
```bash
curl http://localhost:3001/health
# Response: { "status": "ok", "timestamp": "..." }
```

### 3. **Testar Endpoints**
```bash
# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Criar sessão de chat
curl -X POST http://localhost:3001/api/chat/session \
  -H "Authorization: Bearer token-xxx"

# Enviar mensagem
curl -X POST http://localhost:3001/api/chat/send \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "session-xxx",
    "message": "Hello!",
    "model": "gpt-4"
  }'
```

### 4. **Alternar Entre Backends via Console**
```javascript
// No console do browser
toggleFakeBackend(true)  // Ativa fake backend
toggleFakeBackend(false) // Ativa real backend
```

---

## ✅ Checklist

- [ ] Criar `apps/fake-backend` com Express
- [ ] Implementar todas as rotas
- [ ] Criar HTTP Interceptor
- [ ] Integrar no Shell
- [ ] Testar endpoints
- [ ] Documentação completa
- [ ] Docker setup
- [ ] Mock data realista

---

**Status**: Pronto para Implementação ✅
