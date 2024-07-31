import { useState, useEffect } from "react";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import { API } from "./GetAPI";

const ContentSubmitForm = () => {
  const [validConfig, setValidConfig] = useState(true);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [resault, setResault] = useState({
    text: "",
    colorClass: "",
  });

  const good_resault = (msg) => {
    setResault({
      text: `${msg}`,
      colorClass: "text-success",
    });
  };

  const bad_resault = (msg) => {
    setResault({
      text: `${msg}`,
      colorClass: "text-danger",
    });
  };

  const set_sending_state = () => {
    setResault({
      text: "Sending...",
      colorClass: "text-primary",
    });
  };

  useEffect(() => {
    if (API === null) {
      setValidConfig(false);
      bad_resault("API is not set");
    }
  }, []);

  const sendContent = async (form) => {
    form.preventDefault();
    set_sending_state();
    const request_url = API + "/submit_post";

    try {
      let request_body = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: title, body: body }),
      };
      let response = await fetch(request_url, request_body);

      if (!response.ok) {
        let errorResponse = await response.json();
        console.log(errorResponse);
        bad_resault(errorResponse.Error);
        return;
      }

      let response_json = await response.json();
      good_resault(response_json.Message);

      setTitle("");
      setBody("");
      return;
    } catch (e) {
      setValidConfig(false);
      bad_resault("Bad API");
      return;
    }
  };

  if (!validConfig) {
    return (
      <p>
        <span className={resault.colorClass}>{resault.text}</span>
      </p>
    );
  }
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
      {resault.text ? (
        <div style={{ marginBottom: "16px" }}>
          Submit Resault:{" "}
          <span className={resault.colorClass}>{resault.text}</span>
        </div>
      ) : (
        <></>
      )}
      <Button variant="primary" type="submit">
        Submit
      </Button>
      <div id="submit_resault"></div>
    </Form>
  );
};

export default ContentSubmitForm;
