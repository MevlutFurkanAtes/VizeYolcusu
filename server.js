const express = require("express");
const app = express();

app.use(express.json());

let appointment = {
    country: "Germany",
    visaType: "Schengen C",
    isAvailable: false,
    confidenceScore: 0.3,
    lastChecked: new Date()
};

app.get("/appointments", (req, res) => {
    res.json([appointment]);
});

app.post("/report", (req, res) => {
    appointment.confidenceScore += 0.2;

    if (appointment.confidenceScore >= 0.7) {
        appointment.isAvailable = true;
    }

    appointment.lastChecked = new Date();

    res.json({ success: true });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log("Server running on port", PORT);
});