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
// import { gsap } from 'gsap'
import backBtn from '../../components/backBtn.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const world = new CANNON.World()
world.gravity.set(0, -1, 0)

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

const hdr = new RGBELoader().load('/texture/empty_warehouse_01_2k.hdr', (texture) => {
    hdr.mapping = THREE.EquirectangularReflectionMapping
})
const material = new THREE.MeshPhysicalMaterial({
    // color: '#000000',
    transmission: 1.4,
    envMap: hdr,
    envMapIntensity: 1.5,
    clearcoat: 0.3,
    clearcoatRoughness: 0.25,
    ior: 1.25,
    roughness: 0.15,
    metalness: 0,
    thickness: 1.3,
    side: THREE.DoubleSide
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

const mGeo = new THREE.SphereGeometry(2, 12, 12)
const matGeo = new THREE.MeshBasicMaterial({ color: 0xffff00 })
const mouseSphere = new THREE.Mesh(mGeo, matGeo)
mouseSphere.position.z = 19
scene.add(mouseSphere)

const mBodies = new CANNON.Body({
    mass: 0,
    shape: new CANNON.Sphere(2)
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
    <div class="relative">
        <div id="webgl" class="webgl outline-none w-full h-full relative" ref="webgl"></div>
        <backBtn />
    </div>
</template>
