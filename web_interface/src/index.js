import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";

import "bootstrap/dist/css/bootstrap.min.css";

import Navgation from "./componemt/Navgation";
import { APIDisplay, API } from "./componemt/GetAPI";

import Home from "./pages";
import NotFlaggedInterface from "./pages/not_flagged";
import FlaggedInterface from "./pages/flagged";
import SNSControl from "./pages/sns_control";
import FlaggerControl from "./pages/flagger_control";

const NotFound = () => {
  return (
    <>
      <h1 style={{ marginTop: "8px" }}>404 Not Found</h1>
      <p>The page you are looking for does not exist.</p>
    </>
  );
};

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <Navgation />
      <div className="container">
        <Routes>
          <Route exact path="/" element={<Home />} />
          <Route exact path="/flagged" element={<FlaggedInterface />} />
          <Route exact path="/not_flagged" element={<NotFlaggedInterface />} />
          <Route exact path="/sns_controller" element={<SNSControl />} />
          <Route exact path="/flagger_control" element={<FlaggerControl />} />
          <Route exact path="*" element={<NotFound />} />
        </Routes>
      </div>
      <footer className="container">
        <APIDisplay api_url={API} />
        <p>
          Project Repo:{" "}
          <a href="https://github.com/ltekme/AI-Screener-For-User-Generated-Content">
            ltekme/AI-Screener-For-User-Generated-Content
          </a>
        </p>
        {console.log("Hi :]")}
      </footer>
    </BrowserRouter>
  </React.StrictMode>
);
