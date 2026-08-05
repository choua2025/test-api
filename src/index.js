import express from "express";

const app = express();

const port = 6000;

app.get("/", (req, res) => {
    res.send("Hello, World!");
});


const server = app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});


server.on("error", (err) => {
    console.error("Server error:", err);
});


server.on("close", () => {
    console.log("Server closed");
});