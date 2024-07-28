import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";

import "bootstrap/dist/css/bootstrap.min.css";

import Navgation from "./componemt/Navgation";

import Home from "./pages";
import { APIDisplay, API } from "./componemt/GetAPI";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <Navgation />
      <div className="container">
        <Routes>
          <Route exact path="/" element={<Home />} />
        </Routes>
      </div>
      <div className="fixed-bottom container">
        <APIDisplay api_url={API} />
        <p>
          Project Repo:{" "}
          <a href="https://github.com/ltekme/AI-Screener-For-User-Generated-Content">
            ltekme/AI-Screener-For-User-Generated-Content
          </a>
        </p>
      </div>
    </BrowserRouter>
  </React.StrictMode>
);
