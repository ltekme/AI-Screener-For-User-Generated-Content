import { useEffect, useState, useRef } from "react";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

import { API } from "../componemt/GetAPI";

const SNSControl = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [api_satatus, setAPIStatus] = useState("");
  const [api_message, setAPIMessage] = useState("");

  const clear_api = () => {
    setAPIStatus("");
    setAPIMessage("");
  };

  const bad_api = (msg) => {
    setAPIStatus("text-danger");
    setAPIMessage(msg);
  };

  const good_api = (msg) => {
    setAPIStatus("text-success");
    setAPIMessage(msg);
  };

  const getSubscribers = async () => {
    setLoading(true);
    try {
      let response = await fetch(API + "/sns_control");

      if (!response.ok) {
        let errorResponse = await response.json();
        console.log(errorResponse);
        bad_api(errorResponse.Error);
        setLoading(false);
        return;
      }

      let items = await response.json();
      setItems(items);
      return;
    } catch (error) {
      bad_api(error);
      console.log(error);
      return [];
    }
  };

  const newSubscriber = async (e) => {
    e.preventDefault();
    clear_api();
    setLoading(true);

    let formData = new FormData(e.target);

    try {
      let response = await fetch(API + "/sns_control", {
        method: "POST",
        body: JSON.stringify({
          email: formData.get("email"),
        }),
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        let errorResponse = await response.json();
        console.log(errorResponse);
        bad_api(errorResponse.Error);
        setLoading(false);
        return;
      }

      let result = await response.json();
      good_api(result.Message);
      await getSubscribers();
      e.target.reset();
      setLoading(false);
      return;
    } catch (error) {
      console.log(error);
      bad_api(error);
      return;
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      await getSubscribers();
      setLoading(false);
    };
    fetchData();
  }, []);

  return (
    <div>
      <h1>SNS Controller</h1>
      <p>
        This page control the subscription of the SNS topic used to inform
        administrators about flagged content being submitted.
      </p>
      <Form onSubmit={newSubscriber}>
        <Form.Group as={Row}>
          <Col sm="3">
            <Form.Label>New subscriber</Form.Label>
          </Col>
          <Col sm="4">
            <Form.Control
              type="email"
              placeholder="admin@example.com"
              className="mr-2"
              name="email"
            />
          </Col>
          <Col sm="1">
            <Button variant="primary" type="submit">
              Subscribe
            </Button>
          </Col>
        </Form.Group>
      </Form>
      {api_message ? (
        <p>
          State: <span className={api_satatus}>{api_message}</span>
        </p>
      ) : (
        <></>
      )}
      {loading ? <p>Loading...</p> : <></>}
      <table className="table">
        <tbody>
          <tr>
            <th>Email</th>
            <th>Subscription ARN</th>
            <th>Action</th>
          </tr>
          {items.map((item) => {
            console.log(item);
            return (
              <tr key={item.email}>
                <td>{item.email}</td>
                <td>
                  {item.status === "Subscribed" ? (
                    <span className="text-success">{item.status}</span>
                  ) : (
                    <span className="text-danger">{item.status}</span>
                  )}
                </td>
                <td>Nope</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
};

export default SNSControl;
