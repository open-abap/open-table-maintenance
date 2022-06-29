const init = await import("../output/init.mjs");
await init.initializeABAP();
const shim = await import("../output/cl_express_icf_shim.clas.mjs");

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
  };
  console.dir(req);
  await shim.cl_express_icf_shim.run({req: req, res, class: "ZCL_HTTP_HANDLER"})
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

      document.write(r);
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

  await shim.cl_express_icf_shim.run({req: {body: "", method: "GET", path: ""}, res, class: "ZCL_HTTP_HANDLER"});
}

run();
