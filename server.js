const express = require("express");
const app = express();

app.get("/appointments", (req, res) => {
    res.json([{ status: "çalışıyor 🚀" }]);
});

// 🔥 EN KRİTİK SATIR
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log("Server running on port", PORT);
});

app.post("/report", (req, res) => {
    console.log("Report geldi");

    res.json({ success: true });
});
app.use(express.json());