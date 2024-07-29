import React from "react";
import ContentSubmitForm from "../componemt/ContentSubmitForm";

const Home = () => {
  return (
    <>
      <h1 className="text-primary">Send Content</h1>
      <p>
        Write something. After a series of sqs queues and lambda functions, your
        content will be categorized as good and bad.
      </p>
      <ContentSubmitForm />
    </>
  );
};

export default Home;
