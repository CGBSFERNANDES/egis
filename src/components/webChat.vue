<template>
  <!-- vazio, o script já cuidará da exibição do widget -->
  <div></div>
</template>

<script>
export default {
  name: "DigisacWebchat",
  mounted() {
    if (!document.querySelector("script[src*='digisac']")) {
      window._digisac = { id: "f33df97e-e632-4201-9c95-39e1e1a9d847" };

      const script = document.createElement("script");
      script.src = "https://webchat.digisac.app/embedded.js";
      script.async = true;
      document.body.appendChild(script);

      script.onload = () => {
        const interval = setInterval(() => {
          const iframe = document.getElementById("umadivqualquer");
          if (iframe) {
            iframe.style.bottom = "1vh";
            iframe.style.left = "-0.5vw";
            clearInterval(interval);
          }
        }, 500);
      };
    }
  },
};
</script>
