(require (lib "scratch-frisbee.ss" "fluxus-0.15"))

(scene
 (list  
  (factory
   (lambda (e)
     (object #:translate (vec3-integral (vec3 0.0012 0 0))))
   (metro 1.5) 5)))