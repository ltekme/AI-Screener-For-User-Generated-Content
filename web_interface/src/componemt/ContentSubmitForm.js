import { useState } from "react";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import { API } from "./GetAPI";

const ContentSubmitForm = () => {
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [resault, setResault] = useState({
    text: "",
    colorClass: "",
    displayClass: "d-none",
  });

  const good_resault = (msg) => {
    setResault({
      text: `[${msg}]`,
      colorClass: "text-success",
      displayClass: "d-block",
    });
  };

  const bad_resault = (msg) => {
    setResault({
      text: `[${msg}]`,
      colorClass: "text-danger",
      displayClass: "d-block",
    });
  };

  const sendContent = async (form) => {
    form.preventDefault();
    const request_url = API + "/submit_post";

    try {
      let response = await fetch(request_url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ title: title, body: body }),
      });

      if (!response.ok) {
        let errorResponse = await response.json();
        console.log(errorResponse);
        bad_resault(errorResponse.message);
        return;
      }

      let response_json = await response.json();
      console.log("Submitted Content");
      good_resault(response_json.message);

      setTitle("");
      setBody("");
      return;
    } catch (e) {
      console.log(e);
      bad_resault(e);
      return;
    }
  };

  return (
    <Form onSubmit={sendContent}>
      <Form.Group className="mb-3" controlId="title">
        <Form.Label>Title</Form.Label>
        <Form.Control
          type="text"
          placeholder="Enter title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          name="title"
        />
      </Form.Group>
      <Form.Group className="mb-3" controlId="body">
        <Form.Label>Content</Form.Label>
        <Form.Control
          as="textarea"
          rows={3}
          placeholder="Enter body content"
          value={body}
          onChange={(e) => setBody(e.target.value)}
          name="body"
        />
      </Form.Group>
      <div style={{ marginBottom: "16px" }} className={resault.displayClass}>
        Submit Resault:{" "}
        <span className={resault.colorClass}>{resault.text}</span>
      </div>
      <Button variant="primary" type="submit">
        Submit
      </Button>
      <div id="submit_resault"></div>
    </Form>
  );
};

export default ContentSubmitForm;
