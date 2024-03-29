<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import * as THREE from 'three'
import { TextGeometry } from 'three/examples/jsm/geometries/TextGeometry.js'
import { FontLoader } from 'three/examples/jsm/loaders/FontLoader.js'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
import * as CANNON from 'cannon-es'
import { gsap } from 'gsap'
import backBtn from '../../components/backBtn.vue'
import pageWrap from '../../components/pagewrap.vue'
import loadingIco from '../../components/loadingIco.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const world = new CANNON.World()
world.gravity.set(0, -1, 0)
world.broadphase = new CANNON.NaiveBroadphase()
world.allowSleep = true

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

//--------------------------------------------------------------
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
textLoader.load('font/Roboto_Bold.json', (font) => {
    const textGeometry = new TextGeometry('HELLO WORLD', {
        font: font,
        size: 1.1,
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
    text.position.z = -4.5
    scene.add(text)
})

const hdr = new RGBELoader(loadingManager).load('/texture/empty_warehouse_01_2k.hdr', (texture) => {
    hdr.mapping = THREE.EquirectangularReflectionMapping
})
const material = new THREE.MeshPhysicalMaterial({
    transmission: 1.27,
    envMap: hdr,
    envMapIntensity: 9.5,
    // clearcoat: 2.5,
    // clearcoatRoughness: 6.05,
    ior: 1.3,
    roughness: 0.0,
    metalness: 0.1,
    thickness: 1.2
    // side: THREE.DoubleSide
})

const sphereMeshes = []
const sphereBodies = []

for (let x = 0; x < 40; x++) {
    const sphereGeometry = new THREE.SphereGeometry(0.9, 42, 42)
    sphereMeshes.push(new THREE.Mesh(sphereGeometry, material))
    sphereMeshes[x].position.x = Math.random() * 100 - 50
    sphereMeshes[x].position.y = Math.random() * 100 - 50
    sphereMeshes[x].position.z = Math.random() * 100 - 50
    scene.add(sphereMeshes[x])

    const sphereShape = new CANNON.Sphere(0.9)
    sphereBodies.push(new CANNON.Body({ mass: 3 }))
    sphereBodies[x].addShape(sphereShape)
    sphereBodies[x].position.x = sphereMeshes[x].position.x
    sphereBodies[x].position.y = sphereMeshes[x].position.y
    sphereBodies[x].position.z = sphereMeshes[x].position.z
    sphereBodies[x].linearDamping = 0.1 // Damping makes the movement slow down with time
    sphereBodies[x].angularDamping = 0.1
    world.addBody(sphereBodies[x])
}

world.addEventListener('postStep', () => {
    sphereBodies.forEach((s) => {
        const v = new CANNON.Vec3()
        v.set(-s.position.x, -s.position.y, -s.position.z).normalize()
        v.scale(9.82, s.force)
        s.applyLocalForce(v)
        s.force.y += s.mass //cancel out world gravity
    })
})

// mouse

const mGeo = new THREE.SphereGeometry(1, 12, 12)
const matGeo = new THREE.MeshBasicMaterial({ color: 0xffff00 })
const mouseSphere = new THREE.Mesh(mGeo, matGeo)
mouseSphere.position.z = 19
scene.add(mouseSphere)

const mBodies = new CANNON.Body({
    mass: 0,
    shape: new CANNON.Sphere(3)
})
world.addBody(mBodies)

const raycaster = new THREE.Raycaster()
const mouse = new THREE.Vector2(0, 0)

const onMouseMove = (e) => {
    mouse.x = (e.clientX / window.innerWidth) * 2 - 1
    mouse.y = -(e.clientY / window.innerHeight) * 2 + 1
}
window.addEventListener('mousemove', onMouseMove, false)

const touchMove = (e) => {
    const canvas = document.querySelector('canvas')
    const rect = canvas.getBoundingClientRect()
    const scaleX = canvas.width / rect.width
    const scaleY = canvas.height / rect.height

    mouse.x = (((e.touches[0].clientX - rect.left) * scaleX) / canvas.width) * 2 - 1
    mouse.y = (-((e.touches[0].clientY - rect.top) * scaleY) / canvas.height) * 2 + 1
}
window.addEventListener('touchmove', touchMove, false)

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)

    const clock = new THREE.Clock()
    let delta

    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = true
    controls.enabled = false
    controls.maxAzimuthAngle = Math.PI / 4
    controls.minAzimuthAngle = -Math.PI / 4
    controls.minPolarAngle = Math.PI / 2
    controls.maxPolarAngle = Math.PI / 2
    controls.enableZoom = false

    sphereBodies.allowSleep = true

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        delta = Math.min(elapsedTime, 0.08)
        world.step(delta)

        sphereBodies.forEach((s, i) => {
            sphereMeshes[i].position.set(s.position.x, s.position.y, s.position.z)
            sphereMeshes[i].quaternion.set(s.quaternion.x, s.quaternion.y, s.quaternion.z, s.quaternion.w)
        })

        mBodies.position.copy(mouseSphere.position)
        mBodies.quaternion.copy(mouseSphere.quaternion)

        const distance = 19
        raycaster.setFromCamera(mouse, camera)
        const { origin, direction } = raycaster.ray
        mBodies.position.copy(origin.clone().add(direction.multiplyScalar(distance)))

        controls.update()
        renderer.render(scene, camera)
        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(sphereMeshes, text)
    sphereMeshes.length = 0
    sphereBodies.length = 0
    world.removeBody(sphereBodies)
    world.removeBody(mBodies)
    renderer.forceContextLoss()
    renderer.dispose()
    material.dispose()
    hdr.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()
    window.removeEventListener('mousemove', onMouseMove, true)
    window.removeEventListener('touchmove', touchMove, true)
    THREE.Cache.clear()
})
</script>

<template>
    <pageWrap>
        <div v-if="loading" class="z-10 h-screen inset-0 flex items-center justify-center">
            <loadingIco />
        </div>
        <div id="webgl" class="webgl outline-none w-full h-screen" ref="webgl"></div>
        <backBtn />
    </pageWrap>
</template>
