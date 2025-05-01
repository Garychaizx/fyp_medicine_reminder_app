  const express = require("express");
  const cors = require("cors");
  const formData = require("form-data");
  const Mailgun = require("mailgun.js");

  const app = express();
  const PORT = process.env.PORT || 3000;

  app.use(cors());
  app.use(express.json());

  require("dotenv").config()

  // Initialize Mailgun
  const mailgun = new Mailgun(formData);
  const mg = mailgun.client({
    username: "api",
    key: process.env.MAILGUN_API_KEY, // Replace with your Mailgun Private API Key
  });

  const DOMAIN = "sandbox39b1cf2d11794f83b57c7140a807cd26.mailgun.org"; // e.g., sandbox123.mailgun.org

  app.post("/send-email", async (req, res) => {
    const { caregiverEmail, userName, medicationName, suggestedTime, missedCount } = req.body;
  
    console.log("Request body:", req.body);
  
    if (!caregiverEmail || !userName || !medicationName || !suggestedTime || typeof missedCount !== "number") {
      return res.status(400).json({
        error: "Missing or invalid fields: caregiverEmail, userName, medicationName, suggestedTime, or missedCount.",
      });
    }
  
    try {
      const result = await mg.messages.create(DOMAIN, {
        from: "Medication Reminder App <mailgun@sandbox39b1cf2d11794f83b57c7140a807cd26.mailgun.org>",
        to: [caregiverEmail],
        subject: `Missed Medication Alert for ${userName}: ${medicationName}`,
        html: `
          <div style="font-family: Arial, sans-serif; font-size: 16px;">
            <p>Hi,</p>
            <p>This is a notification from the Medication Reminder App.</p>
            <p><strong>${userName}</strong> has missed their medication: <strong>${medicationName}</strong>, 
            which was scheduled at <strong>${suggestedTime}</strong>, a total of <strong>${missedCount}</strong> times.</p>
            <p>Please consider checking in with them to ensure they are managing their medication properly.</p>
            <p>Thank you for supporting their well-being.</p>
            <p>Best regards,<br>Your Medication Reminder App</p>
          </div>
        `,
      });
      res.status(200).json({ message: "Email sent successfully", id: result.id });
    } catch (error) {
      console.error("Mailgun error:", error);
      res.status(500).json({ error: "Failed to send email", details: error.message });
    }
  });
  


  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
