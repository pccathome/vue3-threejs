<script setup>
import date from '../components/date.vue'
</script>
<template>
    <div class="w-screen h-dvh">
        <div class="md:w-[800px] mx-auto flex flex-col md:flex-row space-x-0 md:space-x-6 p-4">
            <section class="w-full flex flex-col items-start">
                <div class="md:h-[250px] mx-auto">
                    <div class="m-20">
                        <div class="mx-auto">
                            <span class="text-base mr-3"> &#128406;</span>
                            <span class="font-neue_hass_roman text-[9px] antialiased uppercase text-white opacity-50">
                                Live &nbsp; long &nbsp; and&nbsp; prosper
                            </span>
                        </div>
                        <ul class="flex justify-center items-center gap-20 pt-10">
                            <li>
                                <a href="https://twitter.com/pccathome" target="_blank">
                                    <img class="h-5 opacity-50 hover:opacity-100" src="../assets/images/twitter.svg" />
                                </a>
                            </li>
                            <li>
                                <a href="https://github.com/pccathome/vue3-threejs" target="_blank">
                                    <img class="h-5 opacity-50 hover:opacity-100" src="../assets/images/github.svg" />
                                </a>
                            </li>
                            <li>
                                <a href="mailto:pccathome@gmail.com">
                                    <img class="h-5 opacity-50 hover:opacity-100" src="../assets/images/mail.svg" />
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/chinese-dragon">
                        <video loop autoplay muted class="shape-inside bg-black">
                            <source id="video-item" src="../assets/video/cdg_2.webm" type="video/webm" />
                            <source id="video-item" src="../assets/video/cdg_2.mp4" type="video/mp4" />
                        </video>
                        <date>2024.01.10</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/audio-visualiser">
                        <div class="shape-inside bg-black">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/audio-v.webm" type="video/webm" />
                                <source src="../assets/video/audio-v.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.12.16</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/liquid-metal">
                        <div class="shape-inside bg-black">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/liquid-cube.webm" type="video/webm" />
                                <source src="../assets/video/liquid-cube.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.11.19</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/balloon">
                        <div class="shape-inside bg-black">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/balloon.webm" type="video/webm" />
                                <source src="../assets/video/balloon.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.11.12</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/3d-noise-bg">
                        <div class="shape-inside bg-black">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/noise-bg.webm" type="video/webm" />
                                <source src="../assets/video/noise-bg.mp4" type="video/mp4" />
                            </video>
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
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/reflation.webm" type="video/webm" />
                                <source src="../assets/video/reflation.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.08.05</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/planes-stencil">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/stencil.webm" type="video/webm" />
                                <source src="../assets/video/stencil.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.08.04</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/point-gravity">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/point-gravity.webm" type="video/webm" />
                                <source src="../assets/video/point-gravity.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.07.15</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/center-gravity">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/center-gravity.webm" type="video/webm" />
                                <source src="../assets/video/center-gravity.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023.07.10</date>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate relative">
                    <router-link to="/transmission-cube">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <video loop autoplay muted class="shape-inside bg-black">
                                <source src="../assets/video/transmission-cube.webm" type="video/webm" />
                                <source src="../assets/video/transmission-cube.mp4" type="video/mp4" />
                            </video>
                        </div>
                        <date>2023. 07. 04</date>
                    </router-link>
                </div>
            </section>
        </div>
    </div>
</template>
