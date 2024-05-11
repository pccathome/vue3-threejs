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
import { gsap } from 'gsap'
import backbtn from '../../components/backBtn.vue'
import pageWrap from '../../components/pagewrap.vue'
import loadingIco from '../../components/loadingIco.vue'

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

// ------------------------------------------------------------
// overlay for loading...
const overlayGeometry = new THREE.PlaneGeometry(2, 2, 1, 1)
const overlayMaterial = new THREE.ShaderMaterial({
    transparent: true,
    uniforms: { uAlpha: { value: 1 } },
    vertexShader: `
        void main() {
            gl_Position = vec4(position, 1.0);
        }
    `,
    fragmentShader: `
        uniform float uAlpha;

        void main() {
            gl_FragColor = vec4(0.0, 0.0, 0.0, uAlpha);
        }
    `
})
const overlay = new THREE.Mesh(overlayGeometry, overlayMaterial)
scene.add(overlay)

const loading = ref(true)
const loadingManager = new THREE.LoadingManager(
    () => {
        gsap.to(overlayMaterial.uniforms.uAlpha, { duration: 3, value: 0 })
        loading.value = false
    },
    (url, loaded, total) => {
        const progress = loaded / total
        console.log(`Loading: ${progress * 100}%`)
    }
)

// Font Loader
const textLoader = new FontLoader()
let text = null
textLoader.load('/font/Roboto_Bold.json', (font) => {
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
const gltfLoader = new GLTFLoader(loadingManager)

let cubeMesh = null
let cubeChild = null
let hdrTexture

const hdrEquirect = new RGBELoader(loadingManager)
hdrEquirect.setPath('/texture/')
gltfLoader.setPath('/models/')
hdrEquirect.load('empty_warehouse_01_2k.hdr', (texture) => {
    hdrTexture = texture
    texture.mapping = THREE.EquirectangularReflectionMapping

    gltfLoader.load('cube.glb', (gltf) => {
        cubeMesh = gltf.scene
        cubeChild = cubeMesh.getObjectByName('cube')
        cubeChild.material = new THREE.MeshPhysicalMaterial({
            transmission: 1.07,
            envMap: texture,
            envMapIntensity: 5.5,
            ior: 1.4,
            roughness: 0,
            metalness: 0.05,
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
    if (cubeMesh) {
        scene.remove(cubeMesh)
        // 遍歷cubeMesh的所有子元素並釋放幾何體和材質
        cubeMesh.traverse((child) => {
            if (child.isMesh) {
                child.geometry.dispose() // 釋放幾何體

                if (child.material.isMaterial) {
                    disposeMaterial(child.material) // 清理材質
                } else if (Array.isArray(child.material)) {
                    // 對於有多個材質的情況
                    child.material.forEach(disposeMaterial)
                }
            }
        })
    }

    // 清理HDR紋理
    if (hdrTexture) {
        hdrTexture.dispose()
    }

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

function disposeMaterial(material) {
    material.dispose() // 釋放材質本身

    // 釋放材質中的紋理
    for (const key of Object.keys(material)) {
        const value = material[key]
        if (value && typeof value === 'object' && 'minFilter' in value) {
            value.dispose()
        }
    }
}
</script>

<template>
    <pageWrap>
        <div v-if="loading" class="h-screen z-10 inset-0 flex items-center justify-center">
            <loadingIco />
        </div>
        <backbtn />
        <div class="outline-none top-0 left-0 w-full h-screen z-0" ref="webgl"></div>
    </pageWrap>
</template>
