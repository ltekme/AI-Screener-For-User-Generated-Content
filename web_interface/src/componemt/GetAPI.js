const GetAPI = async () => {
  let file_content = await fetch("/API.txt");
  let API = file_content.text();
  return API;
};

let API = await GetAPI();

let APIDisplay = ({ api_url }) => {
  return (
    <p style={{ marginTop: "8px" }}>
      Using API: <a href={api_url}>{api_url}</a>
    </p>
  );
};

export default API;
export { API, GetAPI, APIDisplay };
