<script setup>
import date from '../components/date.vue'
</script>
<template>
    <div class="w-screen h-full">
        <div class="md:w-[800px] mx-auto flex flex-col md:flex-row space-x-0 md:space-x-6 p-4">
            <section class="w-full flex flex-col items-start">
                <div class="md:h-[300px] w-full">
                    <div class="m-10 relative">
                        <span class="text-9xl"> &#128406;</span>
                        <p class="absolute top-10 right-10 md:right-16 font-thin text-xs text-white">
                            Live long and prosper
                        </p>
                        <ul class="flex justify-center items-center gap-12 pt-14">
                            <li>
                                <a href="https://twitter.com/pccathome" target="_blank">
                                    <img class="h-6 opacity-50 hover:opacity-100" src="../assets/images/twitter.svg" />
                                </a>
                            </li>
                            <li>
                                <a href="https://github.com/pccathome/vue3-threejs" target="_blank">
                                    <img class="h-6 opacity-50 hover:opacity-100" src="../assets/images/github.svg" />
                                </a>
                            </li>
                            <li>
                                <a href="mailto:pccathome@gmail.com">
                                    <img class="h-6 opacity-50 hover:opacity-100" src="../assets/images/mail.svg" />
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/audio-visualiser">
                        <div class="shape-inside bg-black">
                            <img class="shape-inside" src="../assets/images/audio-veisualiser.png" />
                        </div>
                        <date>2023.12.16</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/liquid-metal">
                        <div class="shape-inside bg-black">
                            <img class="shape-inside" src="../assets/images/liquid-metal.png" />
                        </div>
                        <date>2023.11.19</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/balloon">
                        <div class="shape-inside bg-black">
                            <img class="shape-inside" src="../assets/images/balloon.png" />
                        </div>
                        <date>2023.11.12</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/3d-noise-bg">
                        <div class="shape-inside bg-black">
                            <img class="shape-inside" src="../assets/images/3d-noise-bg.png" />
                        </div>
                        <date>2023.08.13</date>
                    </router-link>
                </div>
            </section>

            <!------------ ------------>

            <section class="w-full flex flex-col items-start text-white md:mt-40">
                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/reflation">
                        <div class="shape-inside bg-black">
                            <img class="shape-inside" src="../assets/images/reflation_1.png" />
                        </div>
                        <date>2023.08.05</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/planes-stencil">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/plane-stencil.png" />
                        </div>
                        <date>2023.08.04</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/point-gravity">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/point-gravity.png" />
                        </div>
                        <date>2023.07.15</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/center-gravity">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/center-gravity.png" />
                        </div>
                        <date>2023.07.10</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/transmission-cube">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/reflation_3.png" />
                        </div>
                        <date>2023.07.04</date>
                    </router-link>
                </div>
            </section>
        </div>
    </div>
</template>
