import { useEffect, useState } from "react";
import { API } from "../componemt/GetAPI";

import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

const FlaggerControl = () => {
  const [loading, setLoading] = useState(true);
  const [apiState, setApiState] = useState("");
  const [apiMessage, setApiMessage] = useState("");
  const [alwaysFlag, setAlwaysFlag] = useState(false);
  const [bypassFlagger, setBypassFlagger] = useState(false);

  const getValuse = async () => {
    setLoading(true);
    try {
      let response = await fetch(API + "/flagger_control");
      if (!response.ok) {
        const errorResponse = await response.json();
        console.log(errorResponse);
        setApiState("text-danger");
        setApiMessage(errorResponse.Error);
        setLoading(false);
        return;
      }
      const data = await response.json();
      setAlwaysFlag(data.always_flag);
      setBypassFlagger(data.bypass_flagger);
      setLoading(false);
    } catch (error) {
      console.log(error);
      setApiState("text-danger");
      setApiMessage(error);
      setLoading(false);
      return;
    }
  };

  const updateValues = async () => {
    setApiState("text-primary");
    setApiMessage("Updating...");
    try {
      let response = await fetch(API + "/flagger_control", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          always_flag: alwaysFlag.toString(),
          bypass_flagger: bypassFlagger.toString(),
        }),
      });
      if (!response.ok) {
        const errorResponse = await response.json();
        console.log(errorResponse);
        setApiState("text-danger");
        setApiMessage(errorResponse.Error);
        return;
      }
      setApiState("text-success");
      setApiMessage("Updated");
    } catch (error) {
      console.log(error);
      setApiState("text-danger");
      setApiMessage(error);
      setLoading(false);
      return;
    }
  };

  useEffect(() => {
    getValuse();
  }, []);

  return (
    <div>
      <div>
        <h1>Flagger Control</h1>
        <p>
          Update the content flagger parameters.
          <span className="text-danger">Always Flag</span> bypasses{" "}
          <span className="text-success">Bypass Content Flagger</span>
        </p>
      </div>
      {apiMessage ? (
        <p>
          API State: <span className={apiState}>{apiMessage}</span>
        </p>
      ) : (
        <></>
      )}
      {loading ? (
        <p>Loading...</p>
      ) : (
        <>
          <Form
            onSubmit={async (e) => {
              e.preventDefault();
              await updateValues();
              return;
            }}
          >
            <Form.Check
              className="text-danger"
              style={{ fontSize: "1.3em" }}
              type="checkbox"
              label="Always Flag Content"
              checked={alwaysFlag}
              onChange={(e) => {
                setAlwaysFlag(e.target.checked);
              }}
            />
            <Form.Check
              className="text-success"
              style={{ fontSize: "1.3em" }}
              type="checkbox"
              label="Bypass Content Flagger"
              checked={bypassFlagger}
              onChange={(e) => {
                setBypassFlagger(e.target.checked);
              }}
            />
            <Button style={{ marginTop: "16px" }} type="submit">
              Update
            </Button>
          </Form>
        </>
      )}
    </div>
  );
};

export default FlaggerControl;
