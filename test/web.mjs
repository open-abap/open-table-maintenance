async function run() {
  const init = await import("../output/init.mjs");
  await init.initializeABAP();
  alert("done");
  const shim = await import("../output/cl_express_icf_shim.clas.mjs");

  let res = {
    append: (data) => {
      console.dir("append: " + data); },
    send: (data) => {
      console.dir("send");
      let r = Buffer.from(data).toString();

      document.write(r);

      setTimeout(() => {
        console.dir("dispatch load");
        window.dispatchEvent(new Event("load"));
      }, 1000);
    },
    status: (status) => {
      console.dir("status: " + status);
      return res; },
  }
  let req = {
    body: "",
    method: "GET",
    path: "/"
  };
  await shim.cl_express_icf_shim.run({req, res, class: "ZCL_HTTP_HANDLER"});
}

run();
