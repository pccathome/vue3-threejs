<script setup>
// const imageUrl = '../assets/images/bg-1.jpg'
</script>
<template>
    <div class="w-screen h-full">
        <div class="md:w-[800px] mx-auto flex flex-col md:flex-row space-x-0 md:space-x-6 p-4">
            <section class="w-full flex flex-col items-start">
                <div class="h-[250px] w-full">
                    <div class="m-10 relative">
                        <span class="text-9xl"> &#128406;</span>
                        <p class="absolute top-10 right-16 font-thin text-xs text-white">Live long and prosper</p>
                    </div>
                </div>

                <div class="shape hover:border-gradient background-animate">
                    <router-link to="/transmission-cube">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/reflation_3.png" />
                        </div>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate">
                    <router-link to="/reflation">
                        <div class="shape-inside bg-black">
                            <img class="shape-inside" src="../assets/images/reflation_1.png" />
                        </div>
                    </router-link>
                </div>

                <!-- <div class="shape hover:border-gradient background-animate">
                    <router-link to="/kanpai">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/reflation_2.png" />
                        </div>
                    </router-link>
                </div> -->
            </section>

            <section class="w-full flex flex-col items-start text-white md:mt-40">
                <div class="shape hover:border-gradient background-animate">
                    <router-link to="/planes-stencil">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/plane-stencil.png" />
                        </div>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate">
                    <router-link to="/point-gravity">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/point-gravity.png" />
                        </div>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate">
                    <router-link to="/center-gravity">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/center-gravity.png" />
                        </div>
                    </router-link>
                </div>

                <!-- <div class="shape hover:border-gradient background-animate">
                    <router-link to="/reflation3">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/reflation_3.png" />
                        </div>
                    </router-link>
                </div>

                <div class="shape hover:border-gradient background-animate">
                    <router-link to="/reflation3">
                        <div class="shape-inside bg-[#F4F4FD]">
                            <img class="shape-inside" src="../assets/images/reflation_3.png" />
                        </div>
                    </router-link>
                </div> -->
            </section>
        </div>
    </div>
</template>
<!-- <style>
.imgSrc {
    background-image: url('../assets/images/bg-3.jpg');
}
</style> -->
