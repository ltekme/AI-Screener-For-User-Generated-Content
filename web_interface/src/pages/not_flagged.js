import React, { useState, useEffect } from "react";

import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

import QueryAPI from "../componemt/QueryAPI";

const NotFlaggedInterface = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [previous_timestamps, setPreviousTimestamps] = useState([]);
  const [last_timestamp, setLastTimestamp] = useState("");
  const [item_per_page, setItemPerPage] = useState(10);

  const prevPage = async () => {
    if (previous_timestamps.length === 0) return;

    setLoading(true);

    // Get the last timestamp from the history
    const newLastTimestamp = previous_timestamps.pop();

    const newItems = await QueryAPI({
      flagged: "false",
      item_per_page: item_per_page,
      last_timestamp: newLastTimestamp,
    });

    setItems(newItems);

    // Update the timestamps
    setLastTimestamp(newLastTimestamp);
    setPreviousTimestamps([...previous_timestamps]);

    setLoading(false);
  };

  const nextPage = async () => {
    setLoading(true);

    // Save the current last timestamp to the history
    setPreviousTimestamps([...previous_timestamps, last_timestamp]);

    const next_query_timestamp = items[items.length - 1].timestamp;

    const newItems = await QueryAPI({
      flagged: "false",
      item_per_page: item_per_page,
      last_timestamp: next_query_timestamp,
    });

    setItems(newItems);

    // Update the last timestamp
    setLastTimestamp(next_query_timestamp);

    setLoading(false);
  };

  const updateQuery = async (e) => {
    e.preventDefault();
    setLoading(true);

    let formData = new FormData(e.target);
    let lastTimestampValue = formData.get("last_timestamp") || "";
    let itemPerPageValue = formData.get("item_per_page") || 10;

    setLastTimestamp(lastTimestampValue);
    setItemPerPage(itemPerPageValue);

    const items = await QueryAPI({
      flagged: "false",
      item_per_page: itemPerPageValue,
      last_timestamp: lastTimestampValue,
    });

    setItems(items);
    setLastTimestamp(
      items.length > 0 ? items[0].timestamp : lastTimestampValue
    );
    setPreviousTimestamps([]);
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
      {loading ? (
        <></>
      ) : (
        <div style={{ display: "flex", justifyContent: "space-between" }}>
          {previous_timestamps.length === 0 ? (
            <></>
          ) : (
            <Button className="btn-sm" onClick={prevPage}>
              Previous Page
            </Button>
          )}
          <Button className="btn-sm" onClick={nextPage}>
            Next Page
          </Button>
        </div>
      )}
    </div>
  );
};

export default NotFlaggedInterface;
