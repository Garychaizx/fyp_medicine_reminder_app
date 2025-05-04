# fyp_medicine_reminder_app

# **Medication Reminder App**

## **Overview**

The **Medication Reminder App** is a comprehensive solution designed to help users manage their medications effectively. It includes features such as medication reminders, adherence tracking, caregiver notifications, refill alerts, and a nearby pharmacy locator. The app aims to improve medication adherence and provide users with tools to stay on top of their health.

---

## **Features**

### 1. **Medication Management**

- Add, edit, and delete medications.
- Specify details such as medication name, dose, frequency, and reminder times.
- Upload optional medication photos for better identification.

### 2. **Medication Reminders**

- Timely notifications to remind users to take their medications.
- Notifications include details like medication name, dose, and an option to mark as "Taken."
- Follow-up reminders for missed doses.

### 3. **Refill Reminders**

- Set inventory thresholds to trigger refill notifications.
- Ensure users never run out of their medications.

### 4. **Adherence Tracking**

- Track doses marked as "Taken" or "Missed."
- Analyze adherence patterns and calculate adherence rates.
- Provide personalized suggestions to improve adherence.

### 5. **Caregiver Notifications**

- Notify caregivers via email when adherence issues are detected.
- Emails include details such as missed doses and suggested new reminder times.
- Powered by a backend using **Mailgun** for reliable email delivery.

### 6. **Nearby Pharmacy Locator**

- Locate pharmacies near the user's current location using the **Google Maps API**.
- Interactive map with markers for nearby pharmacies.

### 7. **User Authentication**

- Secure login and registration using **Firebase Authentication**.
- Protect user data with robust security measures.

### 8. **Offline Functionality**

- Access medication schedules and log adherence even without an internet connection.
- Synchronize data with Firestore when reconnected.

---

## **Technologies Used**

- **Flutter**: For cross-platform mobile app development.
- **Firebase**: For authentication, Firestore database, and cloud storage.
- **Awesome Notifications**: For scheduling and managing local notifications.
- **Google Maps API**: For location-based pharmacy search.
- **Mailgun**: For sending caregiver email notifications.
- **Flutter Dotenv**: For securely managing API keys.

---

## **Installation**

1. **Clone the repository**:
    
    git clone https://github.com/your-repo/medicine_reminder.git
    
2. **Navigate to the project directory**:
    
    cd medicine_reminder
    
3. **Install Flutter dependencies**:
    
    flutter pub get
    
4. **Set up Firebase**:
    - Add your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files.
5. **Configure API keys**:
    - Add your API keys (e.g., Google Maps API, Mailgun API) to the .env file.
6. **Run the Node.js email backend**:
    - Navigate to the emailjs-backend directory:
        
        cd emailjs-backend
        
    - Install dependencies:
        
        npm install
        
    - Start the backend server:
        
        node index.js
        
7. **Run the Flutter app**:
    
    flutter run
    

---

## **Usage**

1. **Add Medications**: Enter medication details, including name, dose, and reminder times.
2. **Receive Notifications**: Get timely reminders and mark medications as "Taken."
3. **Track Adherence**: View adherence logs and suggestions to improve medication-taking habits.
4. **Locate Pharmacies**: Use the pharmacy locator to find nearby pharmacies.
5. **Enable Refill Alerts**: Set inventory thresholds to receive refill notifications.
6. **Caregiver Support**: Notify caregivers about missed doses via email.
