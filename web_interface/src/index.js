import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";

import "bootstrap/dist/css/bootstrap.min.css";

import Navgation from "./componemt/Navgation";

import Home from "./pages";
import { APIDisplay, API } from "./componemt/GetAPI";

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
          <Route exact path="*" element={<NotFound />} />
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
        {console.log('Hi :]')}
      </div>
    </BrowserRouter>
  </React.StrictMode>
);
