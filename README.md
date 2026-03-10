# 🍔 Foodora – Flutter Food Delivery Application

Foodora is a feature-rich food delivery UI application built using the Flutter framework. The project demonstrates how modern food delivery platforms function by combining responsive UI design, user authentication, cart management, and an AI-powered chatbot assistant.

The application is designed to simulate a real-world enterprise-level mobile application with modular architecture and smooth user interaction.

---

# 🚀 Features

### 📱 Cross-Platform Responsive Design

Foodora adapts automatically to different screen sizes. The UI works seamlessly across **mobile and desktop environments**, ensuring consistent layout and interaction without UI overflow issues.

### 🔐 Authentication & User Management

Users can securely register and log in to access their personalized dashboard where they can manage:

* Account details
* Saved delivery addresses
* Order history
* Preferences

### 🍽 Restaurant & Menu Discovery

Foodora provides intuitive discovery features that allow users to explore restaurants and food categories easily.

Key discovery sections include:

* Spotlight Restaurants
* Popular Brands
* Category Based Browsing

Users can also search for dishes or restaurants and filter results by:

* Ratings
* Delivery time
* Dietary preference (Veg / Non-Veg)

### 🛒 Advanced Cart & Order Management

The cart system provides instant feedback when items are added.

Features include:

* Dynamic cart updates
* Coupon discount support
* Order confirmation flow
* Order history tracking
* **One-click reorder functionality**

### 🎨 Engaging UI/UX & Animations

Foodora enhances user engagement through modern UI elements and animations such as:

* Animated promotional banners
* Dynamic food cards
* Delivery tracking animation (Scooty animation)

These elements improve the overall user experience and simulate real delivery tracking.

---

# 🤖 AI Chatbot Assistant

The standout feature of Foodora is its **AI powered conversational assistant**.

Instead of navigating through multiple screens, users can search using natural language queries.

Example:

> “Show me spicy chicken burgers nearby”

The chatbot interprets the request and returns relevant food options directly.

### 🧠 Context-Aware Conversations

The AI assistant maintains conversation context.

Example interaction:

User:

> Show burgers

User:

> Only chicken ones

The system remembers the previous query and filters accordingly.

### ⚡ Predictive Suggestions

The chatbot generates **quick suggestion chips** based on user intent and common queries. Users can tap suggestions for faster interaction.

### 🥗 Dietary Intent Recognition

The AI understands dietary requirements such as:

* Vegetarian
* Vegan
* Non-Vegetarian

The system ensures search results respect these preferences.

### 🔗 Deep App Integration

Unlike standalone chatbots, the assistant directly interacts with the application’s state and menu data.

The chatbot can return **interactive food cards** that allow users to:

* View item details
* Add food directly to the cart
* Navigate to restaurant pages

---

# 🛠 Tech Stack

* **Flutter**
* **Dart**
* **Firebase**
* **Provider (State Management)**
* **Material UI Components**

---

# ⚙️ Installation & Setup

### Clone the repository

```
git clone https://github.com/ASWATH4925/Foodora.git
```

### Navigate to the project

```
cd Foodora
```

### Install dependencies

```
flutter pub get
```

### Run the application

```
flutter run
```

---

# 📂 Project Structure

```
lib/
 ├── models/
 ├── views/
 │   ├── mobile/
 │   └── foodora/
 ├── providers/
 └── main.dart

android/
ios/
```

---

# 👨‍💻 Author

**Aswath**

---

# ⭐ If you like this project

Consider giving the repository a **star ⭐ on GitHub**.
