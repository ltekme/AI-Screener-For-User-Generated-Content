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
        <APIDisplay api_url={API} />
      </div>
    </BrowserRouter>
  </React.StrictMode>
);
