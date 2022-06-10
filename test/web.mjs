async function run() {
  const init = await import("../output/init.mjs");
  await init.initializeABAP();
  const shim = await import("../output/cl_express_icf_shim.clas.mjs");

  let res = {
    append: (data) => {
      console.dir("append: " + data); },
    send: (data) => {
      console.dir("send");
      let r = Buffer.from(data).toString();

      document.write(r);

      globalThis.fetch = (url, options) => {
        console.dir("fetch1");
        console.dir(url);
        console.dir(options);
//        shim.cl_express_icf_shim.run({req: {body: "", method: "GET", path: "/rest"}, res, class: "ZCL_HTTP_HANDLER"});
      };

      setTimeout(() => {
        console.dir("dispatch load");
        window.dispatchEvent(new Event("load"));
      }, 1000);
    },
    status: (status) => {
      console.dir("status: " + status);
      return res; },
  }

  await shim.cl_express_icf_shim.run({req: {body: "", method: "GET", path: "/"}, res, class: "ZCL_HTTP_HANDLER"});
}

run();
