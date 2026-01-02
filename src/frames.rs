use lazy_static::lazy_static;
use std::sync::Arc;

const ANIMATE_FRAMES_STR: [&str; 16] = [
    include_str!("../frames/frame_001.txt"),
    include_str!("../frames/frame_002.txt"),
    include_str!("../frames/frame_003.txt"),
    include_str!("../frames/frame_004.txt"),
    include_str!("../frames/frame_005.txt"),
    include_str!("../frames/frame_006.txt"),
    include_str!("../frames/frame_007.txt"),
    include_str!("../frames/frame_008.txt"),
    include_str!("../frames/frame_009.txt"),
    include_str!("../frames/frame_010.txt"),
    include_str!("../frames/frame_011.txt"),
    include_str!("../frames/frame_012.txt"),
    include_str!("../frames/frame_013.txt"),
    include_str!("../frames/frame_014.txt"),
    include_str!("../frames/frame_015.txt"),
    include_str!("../frames/frame_016.txt"),
];

#[derive(Debug, Clone)]
pub struct Frame {
    pub lines: Arc<[&'static str]>,
}

#[derive(Debug, Clone)]
pub struct AnimatedFrames {
    pub frames: Arc<[Frame]>,
    pub interval_ms: Arc<[u64]>,
}

impl AnimatedFrames {
    pub fn iter(&self) -> AnimatedFramesIterator {
        AnimatedFramesIterator {
            frames: self.frames.clone(),
            interval_ms: self.interval_ms.clone(),
            current_frame: 0,
        }
    }
}

pub struct AnimatedFramesIterator {
    frames: Arc<[Frame]>,
    interval_ms: Arc<[u64]>,
    current_frame: usize,
}

impl Iterator for AnimatedFramesIterator {
    type Item = (Frame, u64);

    fn next(&mut self) -> Option<Self::Item> {
        if self.frames.is_empty() || self.interval_ms.is_empty() {
            return None;
        }
        let max_index = self.frames.len().max(self.interval_ms.len()) - 1;
        if self.current_frame > max_index {
            return None;
        }
        let frame = self.frames[self.current_frame].clone();
        let interval = self.interval_ms[self.current_frame];
        self.current_frame += 1;
        Some((frame, interval))
    }
}

lazy_static! {
    pub static ref ANIMATE_FRAMES: AnimatedFrames = {
        let frames = ANIMATE_FRAMES_STR
            .iter()
            .map(|frame| Frame {
                lines: frame
                    .lines()
                    .map(|line| &line[0..line.len() - 1])
                    .collect(),
            })
            .collect::<Box<[Frame]>>();
        AnimatedFrames {
            frames: Arc::from(frames),
            interval_ms: Arc::new([100; 16]),
        }
    };
}
