import React, { useState } from "react";

import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

import API from "../componemt/GetAPI";

const NotFlaggedInterface = () => {
  const [last_timestamp, setLastTimestamp] = useState();
  const [item_per_page, setItemPerPage] = useState(10);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);

  const queryAPI = async () => {
    setLoading(true);
    try {
      console.log(last_timestamp);
      let queryUrl =
        API +
        "/dynamo_query?" +
        new URLSearchParams({
          flagged: false,
          last_timestamp: last_timestamp,
          item_per_page: item_per_page,
        }).toString();

      console.log(queryUrl);
      let response = await fetch(queryUrl);

      if (!response.ok) {
        let errorResponse = await response.json();
        console.log(errorResponse);
        return;
      }

      setItems(await response.json());
    } catch (error) {
      console.log(error);

      return;
    }
    setLoading(false);
  };

  const updateQuery = async (e) => {
    e.preventDefault();
    let formData = new FormData(e.target);
    setLastTimestamp(formData.get("last_timestamp"));
    setItemPerPage(formData.get("item_per_page"));
		console.log(formData.get("last_timestamp"));
    await queryAPI();
  };

  return (
    <div>
      <h1>Non-Flagged Content</h1>
      <Form onSubmit={updateQuery}>
        <Form.Group as={Row}>
          <Form.Label column sm="3">
            Item Per Page
          </Form.Label>
          <Col sm="4">
            <Form.Control
              type="number"
              placeholder="Item Per Page"
              defaultValue={item_per_page}
              name="item_per_page"
            />
          </Col>
        </Form.Group>
        <Form.Group as={Row}>
          <Form.Label column sm="3">
            Query Item Start Timestamp
          </Form.Label>
          <Col sm="4">
            <Form.Control
              type="datetime-local"
              placeholder=""
              defaultValue={last_timestamp}
              name="last_timestamp"
            />
          </Col>
        </Form.Group>
        <Button variant="primary" type="submit">
          Query
        </Button>
      </Form>
      {loading ? <p>Loading...</p> : <></>}
      <table className="table">
        <tbody>
          <tr>
            <th>Timestamp</th>
            <th>Title</th>
            <th>Content</th>
          </tr>
          {items.map((item) => {
            return (
              <tr key={item.timestamp}>
                <td>{item.timestamp}</td>
                <td>{item.title}</td>
                <td>{item.body}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
};

export default NotFlaggedInterface;