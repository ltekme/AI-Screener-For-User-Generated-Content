import API from "./GetAPI";

const QueryAPI = async ({ flagged, item_per_page, last_timestamp }) => {
  let queryUrl =
    API +
    "/dynamo_query?" +
    new URLSearchParams({
      flagged: flagged,
      last_timestamp: last_timestamp,
      item_per_page: item_per_page,
    }).toString();

  try {
    let response = await fetch(queryUrl);

    if (!response.ok) {
      let errorResponse = await response.json();
      console.log(errorResponse);
      return [];
    }

    return await response.json();
  } catch (error) {
    console.log(error);
    return [];
  }
};

export default QueryAPI;
