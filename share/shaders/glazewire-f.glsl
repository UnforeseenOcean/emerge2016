precision mediump float;

uniform float time;
uniform int motionGate;

varying vec2 vUv;
varying vec3 vPos;
varying float vDepth;


float xWave(float t, float speed, float range, float size ){
	float st = abs( sin(t*speed) * range) - range/2.0 ;
	float x = ceil(vPos.x);
	float minSeg = ceil(640.0/50.0*(st-size/2.0));
	float maxSeg = ceil(640.0/50.0*(st+size/2.0));
	if( x >= minSeg && x <= maxSeg && vDepth > 0.6471 ) return 1.0;
	else return 0.3;
}

void main() {

	float r = abs( sin(  vUv.x + sin(time*0.01) / 5.0 ) );
	float g = abs( sin(  vUv.y + sin(time*0.01) / 4.0 ) );
	float b = abs( sin( -vUv.x + sin(time*0.01) / 3.0 ) );
	
	float alpha = xWave( time, 0.0005, 150.0, 20.0 );

	if( motionGate<=1 )	alpha = alpha;
	else if( motionGate==2 )	alpha = (vDepth<=0.6471) ? 0.0 : 1.0;

	gl_FragColor = vec4( r, g, b, alpha );
		
}