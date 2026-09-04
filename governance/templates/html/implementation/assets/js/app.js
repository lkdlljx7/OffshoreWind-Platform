const action = document.querySelector("#template-action");
const result = document.querySelector("#template-result");

action?.addEventListener("click", () => {
  result.textContent = "原型脚本运行正常。";
});
