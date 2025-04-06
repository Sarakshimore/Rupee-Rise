
# 💸 Rupee Rise — GenAI-Powered Financial Assistant

**Rupee Rise** is a GenAI-based financial assistant designed to democratize access to investing knowledge and decision-making tools in India. With financial literacy levels still low and millions of new investors entering the market, Rupee Rise empowers users with AI-driven conversations to understand investing, discover suitable financial products, and ultimately make better-informed decisions — all at scale.

---

## 🚀 Objective

India is witnessing a surge in retail investors, but there's a massive gap in financial literacy and guidance. Human-driven advisory doesn't scale to the hundreds of millions who need it.

Rupee Rise aims to:

- Provide **conversational financial guidance** using GenAI
- Help users discover and understand **investment products**
- Support **first-time investors** with no prior financial knowledge
- Scale to millions of users using AI-driven support, not manual advisors

---

## 🛠️ Tech Stack

| Technology        | Purpose                                |
|------------------|----------------------------------------|
| **Flutter**       | Cross-platform mobile UI development   |
| **Firebase Auth** | User authentication                    |
| **Firestore DB**  | Real-time cloud database               |
| **Gemini API**    | GenAI-powered conversation engine      |
| **Vertex AI**     | Backend LLM orchestration & deployment |
| **Project IDX**   | AI-assisted development environment    |

---

## 📱 Features

- 🔐 **Secure Login** with email/password or Google
- 🤖 **Rupee Guru - AI Chat Assistant** to ask financial questions easily
- 💡 **Investment Recommendations** based on user queries and preferences
- 📊 **Personalized Guidance** through LLM and Gemini API
- ☁️ **Realtime Sync** of user data via Firestore

---

## 🧪 Installation

### Prerequisites

- Flutter SDK
- Firebase project with Auth and Firestore enabled
- Google Cloud project with Vertex AI + Gemini API enabled
- `google-services.json` in `/android/app/`

### Setup

```bash
git clone https://github.com/Sarakshimore/Rupee-Rise.git
cd rupee-rise
flutter pub get
flutter run
