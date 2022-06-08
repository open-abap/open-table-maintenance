// import {initializeABAP} from "../output/init.mjs";
/*
await initializeABAP();
*/
// import {cl_express_icf_shim} from "../output/cl_express_icf_shim.clas.mjs";

async function foo() {
  const init = await import("../output/init.mjs");
  console.dir(init);
  await init.initializeABAP();
  alert("foo");
}

foo();
