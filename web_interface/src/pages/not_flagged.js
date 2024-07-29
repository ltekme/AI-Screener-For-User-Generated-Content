import React, { useState, useEffect } from "react";

import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

import QueryAPI from "../componemt/QueryAPI";

const NotFlaggedInterface = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);

  const updateQuery = async (e) => {
    e.preventDefault();
    setLoading(true);

    let formData = new FormData(e.target);
    let lastTimestampValue = formData.get("last_timestamp") || "";
    let itemPerPageValue = formData.get("item_per_page") || 10;

    const items = await QueryAPI({
      flagged: "false",
      item_per_page: itemPerPageValue,
      last_timestamp: lastTimestampValue,
    });

    setItems(items);
    setLoading(false);
  };

  useEffect(() => {
    updateQuery({ preventDefault: () => {} });
  }, []);

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
              defaultValue={10}
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
