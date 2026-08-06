import express from "express";

const app = express();

const port = 6000;

app.get("/", (req, res) => {
    res.send("Hello, World this is a test! hhhhh");
});


const server = app.listen(port, () => {
    console.log(`Server is running on http://172.28.14.31:${port}`);
});


server.on("error", (err) => {
    console.error("Server error:", err);
});


server.on("close", () => {
    console.log("Server closed");
});