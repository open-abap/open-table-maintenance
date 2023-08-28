import {initializeABAP} from "../output/_init.mjs";
await initializeABAP();

async function redirectFetch(url, options) {
  let data = "";

  let res = {
    append: (d) => {
      console.dir("append2: " + d); },
    send: (d) => {
      console.dir("send2");
      data = Buffer.from(d).toString();
    },
    status: (status) => {
      console.dir("status2: " + status);
      return res; },
  }

  const method = options?.method || "GET";
  const body = options?.body || "";

  const req = {
    body: Buffer.from(body).toString("hex"),
    method: method,
    path: url,
    url: url,
  };
  console.dir(req);
  await abap.Classes["CL_EXPRESS_ICF_SHIM"].run({req: req, res, class: "ZCL_HTTP_HANDLER"})
  console.log("redirectFetch RESPONSE,");
  console.dir(data);
  return { json: async () => JSON.parse(data)};
}

async function run() {
  let res = {
    append: (data) => {
      console.dir("append: " + data); },
    send: (data) => {
      console.dir("send");
      let r = Buffer.from(data).toString();

      // document.write() doesnt work when loaded from async script
      document.documentElement.innerHTML = r;

      // and setting innerHTML does not automatically load/initialize the scripts
      const scripts = Array.from(document.getElementsByTagName("script"));
{
      var myScript = document.createElement('script');
      myScript.src = scripts[0].src;
      document.head.appendChild(myScript);
}
{
      var myScript = document.createElement('script');
      myScript.src = scripts[1].src;
      document.head.appendChild(myScript);
}
{
      var myScript = document.createElement('script');
      myScript.textContent = scripts[2].textContent;
      document.head.appendChild(myScript);
}

      globalThis.fetch = redirectFetch;

      setTimeout(() => {
        console.dir("dispatch load");
        window.dispatchEvent(new Event("load"));
      }, 1000);
    },
    status: (status) => {
      console.dir("status: " + status);
      return res; },
  }

  await abap.Classes["CL_EXPRESS_ICF_SHIM"].run({req: {body: "", method: "GET", path: "", url: ""}, res, class: "ZCL_HTTP_HANDLER"});
}

run();
