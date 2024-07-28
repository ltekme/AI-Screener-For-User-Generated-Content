const GetAPI = async () => {
  let file_content = await fetch("/API.txt");
  const API = await file_content.text();

  return API.includes("<html>") || !API.startsWith("http") ? null : API;
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
