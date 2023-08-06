<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import * as THREE from 'three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { TextGeometry } from 'three/examples/jsm/geometries/TextGeometry.js'
import { FontLoader } from 'three/examples/jsm/loaders/FontLoader.js'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
// import { gsap } from 'gsap'
import backBtn from '../../components/backBtn.vue'
import footerInfo from '../../components/footerInfo.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const scene = new THREE.Scene()
scene.background = new THREE.Color('#000000')

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

camera.position.z = 19
scene.add(camera)

// Font Loader
const textLoader = new FontLoader()
let text = null
textLoader.load('font/Roboto_Bold.json', (font) => {
    const textGeometry = new TextGeometry('HELLO WORLD', {
        font: font,
        size: 1.5,
        height: 0.001
    })
    const textMaterial = new THREE.MeshBasicMaterial({
        color: new THREE.Color('#ffffff')
        // side: THREE.DoubleSide
    })

    textGeometry.computeBoundingBox()
    textGeometry.translate(
        -textGeometry.boundingBox.max.x * 0.5,
        -textGeometry.boundingBox.max.y * 0.5,
        -textGeometry.boundingBox.max.z * 0.5
    )

    text = new THREE.Mesh(textGeometry, textMaterial)
    text.position.z = -3.5
    scene.add(text)
})

// Model Loader
const gltfLoader = new GLTFLoader()

let cubeMesh = null
let cubeChild = null

const hdrEquirect = new RGBELoader()
hdrEquirect.setPath('/texture/')
gltfLoader.setPath('/models/')
hdrEquirect.load('empty_warehouse_01_2k.hdr', (texture) => {
    texture.mapping = THREE.EquirectangularReflectionMapping

    gltfLoader.load('cube.glb', (gltf) => {
        cubeMesh = gltf.scene
        cubeChild = cubeMesh.getObjectByName('cube')
        cubeChild.material = new THREE.MeshPhysicalMaterial({
            transmission: 1.1,
            envMap: texture,
            envMapIntensity: 5.5,
            ior: 1.3,
            roughness: 0,
            metalness: 0,
            thickness: 1.2,
            side: THREE.DoubleSide
        })
        cubeMesh.scale.set(2, 2, 2)
        scene.add(cubeMesh)
    })
})

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)
    const clock = new THREE.Clock()

    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = true
    controls.enabled = true
    controls.maxAzimuthAngle = Math.PI / 4
    controls.minAzimuthAngle = -Math.PI / 4
    controls.minPolarAngle = Math.PI / 2
    controls.maxPolarAngle = Math.PI / 2
    controls.enableZoom = false

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        if (cubeMesh) {
            cubeMesh.position.y = -0.5 + Math.sin(elapsedTime) * 0.2
            cubeMesh.position.x = -0.5 + Math.cos(elapsedTime) * 0.1
            cubeMesh.rotation.y = elapsedTime * 0.2
            cubeMesh.rotation.x = elapsedTime * 0.4

            const clonedCube = cubeMesh.clone()
            clonedCube.position.set(0, 0, 0)
        }

        controls.update()
        renderer.render(scene, camera)
        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(cubeMesh)
    scene.remove(text)
    renderer.forceContextLoss()
    renderer.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()

    THREE.Cache.clear()
})
</script>

<template>
    <div class="relative">
        <div class="outline-none w-full h-full relative" ref="webgl"></div>
        <backBtn />
        <footerInfo>xxxxx</footerInfo>
    </div>
</template>
