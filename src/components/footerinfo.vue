<template>
    <div class="absolute z-50 ml-5 select-none bottom-24 sm:bottom-6">
        <p class="text-white opacity-50 font-thin text-[0.6rem]">
            <slot name="first">inspired by</slot>
            <span class="font-medium ml-3">
                <slot name="second"></slot>
            </span>
        </p>
    </div>
</template>
