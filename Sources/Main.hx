package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.Scheduler;
import kha.Shaders;
import kha.System;
import kha.graphics4.ConstantLocation;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix3;

class Main {
	static var pipeline: PipelineState;
	static var vertices: VertexBuffer;
	static var indices: IndexBuffer;
	static var texture: Image;
	static var texunit: TextureUnit;
	static var offset: ConstantLocation;
	
	public static function main(): Void {
		System.start({title: "TextureTest", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {
				var structure = new VertexStructure();
				structure.add("pos", VertexData.Short4Norm); //x y z ~
				structure.add("tex", VertexData.Short2Norm); //u v
				
				pipeline = new PipelineState();
				pipeline.inputLayout = [structure];
				pipeline.vertexShader = Shaders.texture_vert;
				pipeline.fragmentShader = Shaders.texture_frag;
				pipeline.compile();

				texunit = pipeline.getTextureUnit("texsampler");
				offset = pipeline.getConstantLocation("mvp");
				
				vertices = new VertexBuffer(4, structure, Usage.StaticUsage);
				var v = vertices.lockInt16();
				var vi = 0;
				v.set( vi++, -10000); v.set( vi++, -10000); v.set( vi++, 12000); v.set( vi++, 0); v.set( vi++, 0); v.set( vi++, 0);
				v.set( vi++,  10000); v.set( vi++, -10000); v.set( vi++, 12000); v.set( vi++, 0); v.set( vi++, 32767); v.set( vi++, 0);
				v.set(vi++, -10000);  v.set(vi++,  10000);  v.set(vi++, 12000);  v.set( vi++, 0); v.set(vi++, 0);  v.set(vi++, 32767);
				v.set(vi++,  10000);  v.set(vi++,  10000);  v.set(vi++, 12000);  v.set( vi++, 0); v.set(vi++, 32767);  v.set(vi++, 32767);
				vertices.unlock();
				
				indices = new IndexBuffer(6, Usage.StaticUsage);
				var i = indices.lock();
				i[0] = 0; i[1] = 1; i[2] = 2;
				i[3] = 2; i[4] = 1; i[5] = 3;
				indices.unlock();
				
				System.notifyOnFrames(render);
			});
		});
	}
	
	private static function render(frames: Array<Framebuffer>): Void {
		var g = frames[0].g4;
		g.begin();
		g.clear(Color.Black);
		g.setPipeline(pipeline);
		g.setMatrix3(offset, FastMatrix3.rotation(Scheduler.realTime()));
		g.setTexture(texunit, Assets.images.parrot);
		g.setVertexBuffer(vertices);
		g.setIndexBuffer(indices);
		g.drawIndexedVertices();
		g.end();
	}
}
