const GetAPI = async () => {
  let file_content = await fetch("/API.txt");
  let file_content_text = await file_content.text();

  return file_content_text.includes("<html>") || !file_content_text.startsWith("http")
    ? window.location.origin + "/api"
    : file_content_text + "/api";
};

let API = await GetAPI();

let APIDisplay = ({ api_url }) => {
  return (
    <>
      {api_url ? (
        <p style={{ marginTop: "8px" }}>
          Using API: <a href={api_url}>{api_url}</a>
        </p>
      ) : (
        <></>
      )}
    </>
  );
};

export default API;
export { API, GetAPI, APIDisplay };
