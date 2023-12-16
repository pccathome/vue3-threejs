import { createRouter, createWebHistory } from 'vue-router'

const routes = [
    {
        path: '/',
        name: 'home',
        component: () => import('../views/home.vue')
    },
    {
        path: '/audio-visualiser',
        name: 'audio-visualiser',
        component: () => import('../views/audio-visualiser/index.vue')
    },
    {
        path: '/liquid-metal',
        name: 'liquid-metal',
        component: () => import('../views/liquid-metal/index.vue')
    },
    {
        path: '/balloon',
        name: 'balloon',
        component: () => import('../views/balloon/index.vue')
    },
    {
        path: '/cloud',
        name: 'cloud',
        component: () => import('../views/cloud/index.vue')
    },
    {
        path: '/3d-noise-bg',
        name: '3d-noise-bg',
        component: () => import('../views/3d-noise-bg/index.vue')
    },
    {
        path: '/reflation',
        name: 'reflation',
        component: () => import('../views/reflation/index.vue')
    },
    {
        path: '//transmission-cube',
        name: '/transmissionCube',
        component: () => import('../views//transmission-cube/index.vue')
    },
    {
        path: '/planes-stencil',
        name: 'planes-stencil',
        component: () => import('../views/planes-stencil/index.vue')
    },
    {
        path: '/center-gravity',
        name: 'center-gravity',
        component: () => import('../views/center-gravity/index.vue')
    },
    {
        path: '/point-gravity',
        name: 'point-gravity',
        component: () => import('../views/point-gravity/index.vue')
    }
]

export default createRouter({
    history: createWebHistory('/'),
    routes
})
