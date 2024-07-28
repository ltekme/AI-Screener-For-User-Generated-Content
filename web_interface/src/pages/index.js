import React from "react";

import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";

const Home = () => {
  return (
    <div className="container">
      <h1 style={{ marginTop: "8px" }}>Write Something</h1>
      <p>
        Project Repo:{" "}
        <a href="https://github.com/ltekme/AI-Screener-For-User-Generated-Content">
          ltekme/AI-Screener-For-User-Generated-Content
        </a>
      </p>
      <Form>
        <Form.Group className="mb-3" controlId="title">
          <Form.Label>Title</Form.Label>
          <Form.Control type="text" placeholder="Enter title" />
        </Form.Group>
        <Form.Group className="mb-3" controlId="body">
          <Form.Label>Content</Form.Label>
          <Form.Control as="textarea" rows={3} placeholder="Enter title" />
        </Form.Group>
        <Button variant="primary" type="submit">
          Submit
        </Button>
      </Form>
    </div>
  );
};

export default Home;
